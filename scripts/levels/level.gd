class_name Level extends Node2D

@export_group("Camera settings")
@export var camera: Camera2D = null

@export_group("Player settings")
@export var player_respawn_timerout: float = 0.5
@export var player_self_destruction_shaking_curve: Curve = null

@onready var player_spawn_marker: Marker2D = %PlayerSpawnMarker

var player: Player = null

func _ready() -> void:
	player_spawn_marker.spawn()

func _on_player_spawn_marker_entity_spawned(entity: Node) -> void:
	if entity is Player:
		player = entity as Player
		player.player_disabled.connect(self._on_player_disabled)
		player.player_destroyed.connect(self._on_player_destroyed)
		player.player_self_destruction_progress.connect(self._on_player_self_destruction_progress)

func _on_player_self_destruction_progress(progress: float) -> void:
	if camera is ShakingCamera and player_self_destruction_shaking_curve:
		camera.apply_shake(player_self_destruction_shaking_curve.sample_baked(progress))

func _on_player_disabled() -> void:
	if camera is ShakingCamera:
		camera.enable_glitches()

func _on_player_destroyed() -> void:
	if camera is ShakingCamera:
		camera.disable_glitches()
		camera.apply_shake()

	player.player_destroyed.disconnect(self._on_player_destroyed)
	player = null
	player_spawn_marker.spawn(player_respawn_timerout)
