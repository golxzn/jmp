class_name Level extends Node2D

@export_group("Camera settings")
@export var camera: Camera2D = null

@onready var player_spawn_marker: Marker2D = %PlayerSpawnMarker

var player: Player = null

func _ready():
	player_spawn_marker.spawn()

func _on_player_spawn_marker_entity_spawned(entity: Node) -> void:
	if entity is Player:
		player = entity as Player
		player.player_destroyed.connect(self._on_player_destroyed)

func _on_player_destroyed():
	player.player_destroyed.disconnect(self._on_player_destroyed)
	player = null
	await get_tree().create_timer(0.5).timeout
	player_spawn_marker.spawn()
