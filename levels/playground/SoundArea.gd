class_name SoundArea extends Node2D

@export var sound: AudioStreamPlayer2D = null
@export var one_shot: bool = false

var played = false

func try_to_play_sound(node: Node2D):
	assert(sound != null, "SoundArea: sound is null")
	if not node is Player: return
	if played: return
	if one_shot: played = true

	sound.play()

