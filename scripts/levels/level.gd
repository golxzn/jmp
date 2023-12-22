class_name Level extends Node2D

@export_group("Camera settings")
@export var camera: Camera2D = null
@export var hud: CanvasLayer = null

@export_group("Player settings")
@export var player_spawner: EntitySpawner = null
@export var player_respawn_timerout: float = 0.5
@export var player_self_destruction_shaking_curve: Curve = null

@export_group("Map settings")
@export var map: TileMap = null

var player: Player = null
var collectables_count: int = 0
var collected_count: int = 0

func _ready() -> void:
	collectables_count = map.get_used_cells(1).size()
	player_spawner.spawn()
	_update_score_label()

func _on_player_spawn_marker_entity_spawned(entity: Node) -> void:
	if entity is Player:
		player = entity as Player
		player.player_disabled.connect(self._on_player_disabled)
		player.player_destroyed.connect(self._on_player_destroyed)
		player.collector.collected.connect(self._on_collector_collect_value)
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
	player_spawner.spawn(player_respawn_timerout)

func _on_collector_collect_value(score: int) -> void:
	# TODO: Fix this shit
	collected_count += score
	_update_score_label()

func _update_score_label() -> void:
	if hud:
		var label: Label = hud.find_child("ScoreLabel")
		if label:
			label.text = "Score: %4d/%4d" % [collected_count, collectables_count]

