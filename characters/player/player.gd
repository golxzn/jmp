class_name Player extends CharacterBody2D

#region signals

signal dash(player: Player, state: String, is_last_chance: bool)
signal jump(player: Player, state: String, is_last_chance: bool)

#endregion signals

#region constants
const LAST_CHANCE: bool = true
const NOT_LAST_CHANCE: bool = false

const SPEED: float         = 300.0
const MAXIMUM_SPEED: float = 600.0

const DASH_SPEED: float    = 500.0
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
#endregion constants

#region export variables
@export_category("Movement")
@export var accelerations: Dictionary = {
	PlacemantState.Ground: 4000.0,
	PlacemantState.Coyote: 300.0,
	PlacemantState.MidAir: 300.0,
	PlacemantState.Wall:   2000.0,
}
@export var dash_speed_curve: Curve = load("uid://b4gxfw82qvdds")
@export var climb_resistance_curve: Curve = load("uid://bvfqik0okq6ni")
@export_category("Movement Sounds")
#endregion export variables

#region onready variables
@onready var coyote_timer: CoyoteTimer = $Timers/CoyoteTimer
@onready var dashing_timer: DashingTimer = $Timers/DashingTimer
@onready var climbing_timer: ClimbingTimer = $Timers/ClimbingTimer

@onready var ray_to_bottom: RayCast2D = $PlayerCollision/RayToBottom
@onready var state_chart: StateChart = $StateChart
#endregion onready variables

enum Face { Left = -1, Right = 1 }
var face_direction: Face = Face.Right

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var current_state: String = PlacemantState.MidAir
var was_on_floor: bool = false
var was_on_wall: bool = false
var ask_for_jump: bool = false
var ask_for_dash: bool = false

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

func _process(_delta: float):
	state_chart.set_expression_property("is_moving", is_moving())
	state_chart.set_expression_property("is_on_wall_only", is_on_wall_only())

func _physics_process(delta: float):
	check_climbing()
	check_coyote()
	check_gravity(delta)

	velocity = velocity.limit_length(MAXIMUM_SPEED)

	move_and_slide()

func _input(event: InputEvent):
	if event.is_action_pressed("jump"):
		ask_for_jump = true
	if event.is_action_pressed("dash"):
		ask_for_dash = true

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

	if dashing_timer.can_dash():
		dashing_timer.start_dash()
		velocity = get_face_direction_vector() * (DASH_SPEED * dash_velocity_modifier)
		return true
	return false

func check_climbing():
	var only_on_wall: bool = is_on_wall_only()

	if only_on_wall:
		if not was_on_wall:
			climbing_timer.start()
			set_state(PlacemantState.Wall)
	elif climbing_timer.is_climbing():
		climbing_timer.stop()

	was_on_wall = only_on_wall

func check_coyote():
	var on_floor: bool = is_on_floor()

	if on_floor:
		set_state(PlacemantState.Ground)
		if coyote_timer.is_coyote():
			coyote_timer.stop()
		elif climbing_timer.is_climbing():
			climbing_timer.stop()
	elif was_on_floor and velocity.y >= 0: # ensure it's coyote situation, isn't jump
		coyote_timer.start()
		set_state(PlacemantState.Coyote)
	elif not coyote_timer.is_coyote() and not climbing_timer.is_climbing():
		set_state(PlacemantState.MidAir)

	was_on_floor = on_floor

func check_gravity(delta: float):
	var on_floor: bool = is_on_floor()

	if on_floor:
		set_state(PlacemantState.Ground)
	elif not dashing_timer.is_dashing():
		velocity += -up_direction * gravity * get_climbing_gravity_modifier() * delta



func movement(acceleration: float, delta: float):
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction:
		face_direction = Face.Left if direction < 0 else Face.Right
		# velocity.x = direction * actual_speed()
		velocity.x = move_toward(velocity.x, direction * actual_speed(), acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)

#endregion Movement

#region Collision callbacks

func _on_hit_box_body_entered(body: Node2D):
	print("On hit box body entered: ", str(body))
	state_chart.send_event("player_state/die")

#endregion Collision callbacks

#region Timers timeout callbacks

func _on_climbing_timer_timeout():
	# Climbing timer is out. We cannot be on the wall anymore
	set_state(PlacemantState.Ground if is_on_floor() else PlacemantState.MidAir)

func _on_dashing_timer_timeout():
	if is_on_wall_only():
		set_state(PlacemantState.Wall)
	elif is_on_floor():
		set_state(PlacemantState.Ground)
	else:
		set_state(PlacemantState.MidAir)

func _on_coyote_timer_timeout():
	# The very last chanse to jump or dash
	# We should revard players by allowing them to
	# jump higher and dash futher

	if jump_if_possible(JUMP_VELOCITY_MODIFIER): jump.emit(self, PlacemantState.Coyote, LAST_CHANCE)
	if dash_if_possible(DASH_VELOCITY_MODIFIER): dash.emit(self, PlacemantState.Coyote, LAST_CHANCE)

	set_state(PlacemantState.Wall if is_on_wall_only() else PlacemantState.MidAir)

#endregion

#region States

func set_state(state: String):
	# print("Change state from [%s] to [%s]" % [current_state, state])
	if state != current_state:
		current_state = state
		state_chart.send_event(current_state)

func _on_ground_state_physics_processing(delta: float):
	# On ground we can:
	# - move left/right
	# - jump
	# - dash
	if jump_if_possible(): jump.emit(self, PlacemantState.Ground, NOT_LAST_CHANCE)
	if dash_if_possible(): dash.emit(self, PlacemantState.Ground, NOT_LAST_CHANCE)

	movement(accelerations[PlacemantState.Ground], delta)


func _as_coyote_state_physics_processing(delta: float):
	# As a coyote we can same as on ground state, but with benefits
	if jump_if_possible(JUMP_VELOCITY_MODIFIER): jump.emit(self, PlacemantState.Coyote, NOT_LAST_CHANCE)
	if dash_if_possible(DASH_VELOCITY_MODIFIER): dash.emit(self, PlacemantState.Coyote, NOT_LAST_CHANCE)
	movement(accelerations[PlacemantState.Coyote], delta)


func _in_air_state_physics_processing(delta: float):
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


func _on_wall_state_physics_processing(delta: float):
	# On the wall we can:
	# - move to the opposite side (with timeout, like 0.5 - 1.0 seconds to hold the key)
	# - jump (only to the opposite side of the wall) | ->
	# - dash (only to the opposite side of the wall) | ->
	if not climbing_timer.is_climbing():
		set_state(PlacemantState.MidAir)

	var wall_normal: Vector2 = get_wall_normal()
	if ask_for_jump:
		ask_for_jump = false
		set_state(PlacemantState.MidAir)
		velocity = (wall_normal + up_direction).normalized() * JUMP_VELOCITY
		jump.emit(self, PlacemantState.Wall, NOT_LAST_CHANCE)

	if ask_for_dash:
		ask_for_dash = false
		set_state(PlacemantState.MidAir)
		dashing_timer.start_dash()
		dash.emit(self, PlacemantState.Wall, NOT_LAST_CHANCE)
		velocity = wall_normal * DASH_SPEED

	movement(accelerations[PlacemantState.Wall], delta)

#endregion
