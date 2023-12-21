@tool
class_name Teleport extends Node2D

@export var apply_velocity: Vector2 = Vector2.ZERO
@export var destination: Marker2D = null

func teleport(body: Node2D):
	if not body.is_in_group("teleportable"): return

	assert(destination != null, "Teleport: destination is null")
	body.global_position = destination.global_position
	if apply_velocity:
		body.velocity = apply_velocity

func _draw() -> void:
	if Engine.is_editor_hint() and destination != null:
		draw_dashed_line(Vector2.ZERO, destination.position, Color.GREEN_YELLOW)

