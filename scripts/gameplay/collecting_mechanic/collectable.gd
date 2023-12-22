class_name Collectable extends Area2D

signal collected(collectable: Collectable)

enum CollectableState { Collected, Uncollected }

@export var value: int = 1
@export var state: CollectableState = CollectableState.Uncollected
@export var collect_sound: AudioStreamPlayer2D = null

func _init() -> void:
	add_to_group("collectable")

func _ready() -> void:
	collect_sound.finished.connect(self._on_collect_sound_finished)

func is_collected() -> bool:
	return state == CollectableState.Collected

func collect() -> int:
	if is_collected(): return 0

	state = CollectableState.Collected
	if collect_sound: collect_sound.play()
	collected.emit(self)
	visible = false
	return value;

func destroy() -> void:
	call_deferred("queue_free")


func _on_collect_sound_finished() -> void:
	destroy()

