class_name SoundManager extends Node2D

@export_group("Dash sounds")
@export var ground_dash: AudioStreamPlayer  = null
@export var coyote_dash: AudioStreamPlayer  = null
@export var mid_air_dash: AudioStreamPlayer = null
@export var wall_dash: AudioStreamPlayer    = null

@export_group("Jump sounds")
@export var ground_jump: AudioStreamPlayer  = null
@export var coyote_jump: AudioStreamPlayer  = null
@export var mid_air_jump: AudioStreamPlayer = null
@export var wall_jump: AudioStreamPlayer    = null

@export_group("Behaviour sounds")
@export var disabling: AudioStreamPlayer = null
@export var assembling: AudioStreamPlayer = null
@export var destroying: AudioStreamPlayer = null

enum Playlists{ Jump, Dash }

@onready var playlists: Dictionary = {
	Playlists.Jump: {
		Player.PlacemantState.Ground: ground_jump,
		Player.PlacemantState.Coyote: coyote_jump,
		Player.PlacemantState.MidAir: mid_air_jump,
		Player.PlacemantState.Wall  : wall_jump
	},
	Playlists.Dash: {
		Player.PlacemantState.Ground: ground_dash,
		Player.PlacemantState.Coyote: coyote_dash,
		Player.PlacemantState.MidAir: mid_air_dash,
		Player.PlacemantState.Wall  : wall_dash
	}
}

func safe_play(playlist: Dictionary, state: String):
	if state not in playlist:
		print_debug("Cannot find sound for state '%s'" % state)
		return

	var sound: AudioStreamPlayer = playlist[state]
	if sound: sound.play()


func _on_player_dash(_player: Player, state: String, _is_last_chance: bool):
	safe_play(playlists[Playlists.Dash], state)


func _on_player_jump(_player: Player, state: String, _is_last_chance: bool):
	safe_play(playlists[Playlists.Jump], state)


func _on_player_player_disabled() -> void:
	if disabling: disabling.play()


func _on_player_player_destroyed() -> void:
	if destroying: destroying.play()


func _on_player_player_assembled() -> void:
	if assembling: assembling.play()