class_name EntitySpawner extends Marker2D

signal entity_spawned(entity: Node)

@export var entity_to_spawn: PackedScene = null
@export var node_to_place: Node = null
@export var child_index: int = 0
@export var camera_to_set: Camera2D = null

func spawn(delay: float = 0.0):
	assert(node_to_place != null, "Set node to place entity in editor")
	assert(entity_to_spawn != null, "I don't know whom I need to spawn")

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	var entity: Node2D = entity_to_spawn.instantiate()
	entity.global_position = global_position
	if camera_to_set != null:
		var remote_transform: RemoteTransform2D = RemoteTransform2D.new()
		remote_transform.update_scale = false
		remote_transform.update_rotation = false
		remote_transform.use_global_coordinates = true
		remote_transform.remote_path = camera_to_set.get_path()
		entity.add_child(remote_transform)

	node_to_place.add_child(entity)
	node_to_place.move_child(entity, child_index)
	entity_spawned.emit(entity)
