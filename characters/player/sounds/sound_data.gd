class_name SoundData extends Resource

@export var default_sound: AudioStream = null
@export var default_sound_start: float = 0.0
@export var last_chance_sound: AudioStream = null
@export var last_chance_sound_start: float = 0.0

func _init(sound: AudioStream = null, start: float = 0.0, last_chance: AudioStream = null, last_chance_start: float = 0.0):
	self.default_sound = sound
	self.default_sound_start = start
	self.last_chance_sound = last_chance if last_chance != null else sound
	self.last_chance_sound_start = last_chance_start if last_chance != null else start

func play(player: AudioStreamPlayer, last_chance: bool):
	assert(self.default_sound != null, "[SoundData] Initializing with null sound")

	if not last_chance: safe_play(player, default_sound, default_sound_start)
	else: safe_play(player, last_chance_sound, last_chance_sound_start)

func safe_play(player: AudioStreamPlayer, sound: AudioStream, start: float = 0.0):
	if player and sound:
		player.stream = sound
		player.play(start)

