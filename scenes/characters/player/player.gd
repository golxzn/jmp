class_name Player extends CharacterBody2D

#region signals

signal player_assembled
signal player_disabled
signal player_destroyed
signal palyer_self_destruction_started
signal player_self_destruction_progress(progress: float)
signal palyer_self_destruction_interrupted

signal dash(player: Player, state: String, is_last_chance: bool)
signal jump(player: Player, state: String, is_last_chance: bool)

#endregion signals

#region constants
const LAST_CHANCE: bool = true
const NOT_LAST_CHANCE: bool = false

const SPEED: float         = 300.0
const MAXIMUM_SPEED: float = 600.0

const DASH_SPEED: float    = 400.0
const DASH_VELOCITY_MODIFIER: float = 1.3
const DASH_VELOCITY_DEFAULT_MODIFIER: float = 1.0

const JUMP_VELOCITY: float = 400.0
const JUMP_VELOCITY_MODIFIER: float = 1.3
const JUMP_BONNY_HOP_VELOCITY_MODIFIER: float = 1.1
const JUMP_VELOCITY_DEFAULT_MODIFIER: float = 1.0

const VELOCITY_TRESHOLD: float = 0.01

class PlacemantState:
	const Ground: String = 'placemant_state/ground'
	const Coyote: String = 'placemant_state/coyote'
	const MidAir: String = 'placemant_state/mid_air'
	const Wall: String   = 'placemant_state/wall'

class PlayerState:
	const Enable:  String = 'player_state/enable'
	const Disable: String = 'player_state/disable'

class Animations:
	const Spawn: String = 'player_spawn'
	const Death: String = 'player_death'

#endregion constants

#region export variables
@export_category("Movement")
@export var accelerations: Dictionary = {
	PlacemantState.Ground: 4000.0,
	PlacemantState.Coyote: 300.0,
	PlacemantState.MidAir: 300.0,
	PlacemantState.Wall:   2000.0,
}
@export var max_dash_count: int = 1
@export var dash_speed_curve: Curve = load("uid://b4gxfw82qvdds")
@export var climb_resistance_curve: Curve = load("uid://bvfqik0okq6ni")

@export var disabled_to_death_delay: float = 1.0
#endregion export variables

#region onready variables
@onready var coyote_timer: CoyoteTimer = $Timers/CoyoteTimer
@onready var dashing_timer: DashingTimer = $Timers/DashingTimer
@onready var climbing_timer: ClimbingTimer = $Timers/ClimbingTimer
@onready var self_destruction_timer: ProgressTimer = $Timers/SelfDestructionTimer

@onready var ray_to_bottom: RayCast2D = $PlayerCollision/RayToBottom
@onready var state_chart: StateChart = $StateChart

@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var broken_lighting: Control = $VFX/BrokenLightings
#endregion onready variables

enum Face { Left = -1, Right = 1 }
var face_direction: Face = Face.Right

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var current_movement_state: String = PlacemantState.MidAir
var current_player_state: String = PlayerState.Disable
var dash_count: int = max_dash_count
var was_on_floor: bool = false
var was_on_wall: bool = false
var ask_for_jump: bool = false
var ask_for_dash: bool = false

func is_enabled()  -> bool: return current_player_state == PlayerState.Enable
func is_disabled() -> bool: return current_player_state == PlayerState.Disable

func spawn():
	broken_lighting.visible = false
	animations.play(Animations.Spawn)
	await animations.animation_finished
	set_player_state(PlayerState.Enable)
	player_assembled.emit()

func die():
	broken_lighting.visible = true
	set_player_state(PlayerState.Disable)
	player_disabled.emit()

func destroy():
	broken_lighting.visible = false
	animations.play(Animations.Death)
	await animations.animation_finished
	player_destroyed.emit()
	call_deferred("queue_free")


func get_climbing_gravity_modifier() -> float:
	if climbing_timer.is_climbing():
		return climb_resistance_curve.sample_baked(climbing_timer.progress())
	return climb_resistance_curve.sample_baked(1.0)

func get_dash_modifier() -> float:
	if dashing_timer.is_dashing():
		return dash_speed_curve.sample_baked(dashing_timer.progress())
	return dash_speed_curve.sample_baked(1.0)

func is_moving() -> bool:
	return (abs(velocity.x) < VELOCITY_TRESHOLD and abs(velocity.y) < VELOCITY_TRESHOLD)

func can_jump() -> bool:
	if coyote_timer.is_coyote():
		return true
	return is_on_floor() or ray_to_bottom.is_colliding()

func actual_speed() -> float:
	return SPEED + (DASH_SPEED * get_dash_modifier())

func get_face_direction_vector() -> Vector2:
	return Vector2(float(face_direction), 0.0)

#region Default overrided methods

func _ready():
	if not OS.is_debug_build():
		$DebugCanvasLayer.queue_free()
		remove_child($DebugCanvasLayer)

	climbing_timer.timeout.connect(self._on_climbing_timer_timeout)
	dashing_timer.timeout.connect(self._on_dashing_timer_timeout)
	coyote_timer.timeout.connect(self._on_coyote_timer_timeout)
	self_destruction_timer.timeout.connect(self._on_self_destruction_timer_timeout)

	spawn()

func _process(_delta: float):
	state_chart.set_expression_property("is_moving", is_moving())
	state_chart.set_expression_property("is_on_wall_only", is_on_wall_only())
	if not self_destruction_timer.is_stopped():
		player_self_destruction_progress.emit(self_destruction_timer.progress())

func _physics_process(delta: float):
	check_climbing()
	check_coyote()
	check_gravity(delta)

	if is_disabled() and velocity.x:
		velocity.x = move_toward(velocity.x, 0, accelerations[PlacemantState.Ground] * delta)

	move_and_slide()

func _input(event: InputEvent):
	if Focus.event_is_action_pressed(event, "jump"): ask_for_jump = true
	if Focus.event_is_action_pressed(event, "dash"): ask_for_dash = true
	if Focus.event_is_action_pressed(event, "self_destruction"):
		self_destruction_timer.start()
		palyer_self_destruction_started.emit()
	elif Focus.event_is_action_released(event, "self_destruction"):
		self_destruction_timer.stop()
		palyer_self_destruction_interrupted.emit()

#endregion Default overrided methods

#region Movement

func jump_if_possible(jump_velocity_modifier: float = JUMP_VELOCITY_DEFAULT_MODIFIER) -> bool:
	if not ask_for_jump: return false
	ask_for_jump = false

	if can_jump():
		velocity += up_direction * (JUMP_VELOCITY * jump_velocity_modifier)
		return true
	return false

func dash_if_possible(dash_velocity_modifier: float = DASH_VELOCITY_DEFAULT_MODIFIER) -> bool:
	if not ask_for_dash: return false
	ask_for_dash = false

	if dash_count != 0 and dashing_timer.can_dash():
		dash_count -= 1
		dashing_timer.start_dash()
		velocity = get_face_direction_vector() * (DASH_SPEED * dash_velocity_modifier)
		return true
	return false

func check_climbing():
	var only_on_wall: bool = is_on_wall_only()

	if only_on_wall:
		if not was_on_wall:
			climbing_timer.start()
			set_movement_state(PlacemantState.Wall)
	elif climbing_timer.is_climbing():
		climbing_timer.stop()

	was_on_wall = only_on_wall

func check_coyote():
	var on_floor: bool = is_on_floor()

	if on_floor:
		set_movement_state(PlacemantState.Ground)
		if coyote_timer.is_coyote():
			coyote_timer.stop()
		elif climbing_timer.is_climbing():
			climbing_timer.stop()
	elif was_on_floor and velocity.y >= 0: # ensure it's coyote situation, isn't jump
		coyote_timer.start()
		set_movement_state(PlacemantState.Coyote)
	elif not coyote_timer.is_coyote() and not climbing_timer.is_climbing():
		set_movement_state(PlacemantState.MidAir)

	was_on_floor = on_floor

func check_gravity(delta: float):
	var on_floor: bool = is_on_floor()

	if on_floor:
		set_movement_state(PlacemantState.Ground)
		dash_count = max_dash_count
	elif not dashing_timer.is_dashing():
		velocity += -up_direction * gravity * get_climbing_gravity_modifier() * delta



func movement(acceleration: float, delta: float):
	var direction: float = Focus.get_axis("move_left", "move_right")
	if direction:
		face_direction = Face.Left if direction < 0 else Face.Right
		# velocity.x = direction * actual_speed()
		velocity.x = move_toward(velocity.x, direction * actual_speed(), acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)

#endregion Movement

#region Collision callbacks

func _on_hit_box_body_entered(body: Node2D):
	# TODO: Make it more universal. Body has to be able to tell us what to do or kinda
	print("On hit box body entered: ", str(body))
	die()
	await get_tree().create_timer(disabled_to_death_delay).timeout
	destroy()

#endregion Collision callbacks

#region Timers timeout callbacks

func _on_climbing_timer_timeout():
	# Climbing timer is out. We cannot be on the wall anymore
	set_movement_state(PlacemantState.Ground if is_on_floor() else PlacemantState.MidAir)

func _on_dashing_timer_timeout():
	if is_on_wall_only():
		set_movement_state(PlacemantState.Wall)
	elif is_on_floor():
		set_movement_state(PlacemantState.Ground)
	else:
		set_movement_state(PlacemantState.MidAir)

func _on_coyote_timer_timeout():
	# The very last chanse to jump or dash
	# We should revard players by allowing them to
	# jump higher and dash futher

	if jump_if_possible(JUMP_VELOCITY_MODIFIER): jump.emit(self, PlacemantState.Coyote, LAST_CHANCE)
	if dash_if_possible(DASH_VELOCITY_MODIFIER): dash.emit(self, PlacemantState.Coyote, LAST_CHANCE)

	set_movement_state(PlacemantState.Wall if is_on_wall_only() else PlacemantState.MidAir)

func _on_self_destruction_timer_timeout() -> void:
	destroy()

#endregion

#region Movement States

func set_movement_state(state: String):
	# print("Change state from [%s] to [%s]" % [current_movement_state, state])
	if state != current_movement_state:
		current_movement_state = state
		state_chart.send_event(current_movement_state)

func _on_ground_state_physics_processing(delta: float):
	if is_disabled(): return
	# On ground we can:
	# - move left/right
	# - jump
	# - dash
	if jump_if_possible(): jump.emit(self, PlacemantState.Ground, NOT_LAST_CHANCE)
	if dash_if_possible(): dash.emit(self, PlacemantState.Ground, NOT_LAST_CHANCE)

	movement(accelerations[PlacemantState.Ground], delta)

	velocity = velocity.limit_length(MAXIMUM_SPEED)


func _as_coyote_state_physics_processing(delta: float):
	if is_disabled(): return
	# As a coyote we can same as on ground state, but with benefits
	if jump_if_possible(JUMP_VELOCITY_MODIFIER): jump.emit(self, PlacemantState.Coyote, NOT_LAST_CHANCE)
	if dash_if_possible(DASH_VELOCITY_MODIFIER): dash.emit(self, PlacemantState.Coyote, NOT_LAST_CHANCE)
	movement(accelerations[PlacemantState.Coyote], delta)

	velocity = velocity.limit_length(MAXIMUM_SPEED)


func _in_air_state_physics_processing(delta: float):
	if is_disabled(): return
	# Mid air we can:
	# - move left/right
	# - dash
	# - jump (only if we're near the floor. It's bonny hop)

	if dash_if_possible(): dash.emit(self, PlacemantState.MidAir, NOT_LAST_CHANCE)

	if ask_for_jump and can_jump():
		velocity.y = 0
		velocity += up_direction * (JUMP_VELOCITY * JUMP_BONNY_HOP_VELOCITY_MODIFIER)
		jump.emit(self, PlacemantState.MidAir, NOT_LAST_CHANCE)

	ask_for_jump = false

	movement(accelerations[PlacemantState.MidAir], delta)

	if is_on_wall():
		velocity = velocity.limit_length(MAXIMUM_SPEED)


func _on_wall_state_physics_processing(delta: float):
	if is_disabled(): return
	# On the wall we can:
	# - move to the opposite side (with timeout, like 0.5 - 1.0 seconds to hold the key)
	# - jump (only to the opposite side of the wall) | ->
	# - dash (only to the opposite side of the wall) | ->
	if not climbing_timer.is_climbing():
		set_movement_state(PlacemantState.MidAir)
	elif is_on_floor():
		set_movement_state(PlacemantState.Ground)

	if not is_on_floor():
		var wall_normal: Vector2 = get_wall_normal()
		if ask_for_jump:
			ask_for_jump = false
			set_movement_state(PlacemantState.MidAir)
			velocity = (wall_normal + up_direction).normalized() * JUMP_VELOCITY
			jump.emit(self, PlacemantState.Wall, NOT_LAST_CHANCE)

		if ask_for_dash:
			ask_for_dash = false
			set_movement_state(PlacemantState.MidAir)
			dashing_timer.start_dash()
			dash.emit(self, PlacemantState.Wall, NOT_LAST_CHANCE)
			velocity = wall_normal * DASH_SPEED

	else:
		if jump_if_possible(): jump.emit(self, PlacemantState.Ground, NOT_LAST_CHANCE)
		if dash_if_possible(): dash.emit(self, PlacemantState.Ground, NOT_LAST_CHANCE)

	movement(accelerations[PlacemantState.Wall], delta)

	velocity = velocity.limit_length(MAXIMUM_SPEED)

#endregion Movement States

#region Player states

func set_player_state(state: String):
	if state != current_player_state:
		current_player_state = state
		state_chart.send_event(current_player_state)

func _on_enable_state_entered():
	spawn()

#region Player states

