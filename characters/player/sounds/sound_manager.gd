class_name SoundManager extends Node2D

var ground_dash: SoundData  = load("res://characters/player/sounds/data/dash/on_ground.tres")
var coyote_dash: SoundData  = load("res://characters/player/sounds/data/dash/coyote.tres")
var mid_air_dash: SoundData = load("res://characters/player/sounds/data/dash/mid_air.tres")
var wall_dash: SoundData    = load("res://characters/player/sounds/data/dash/on_wall.tres")

var ground_jump: SoundData = load("res://characters/player/sounds/data/jump/on_ground.tres")
var coyote_jump: SoundData = load("res://characters/player/sounds/data/jump/coyote.tres")
var mid_air_jump: SoundData = load("res://characters/player/sounds/data/jump/mid_air.tres")
var wall_jump: SoundData   = load("res://characters/player/sounds/data/jump/on_wall.tres")

@export var player: AudioStreamPlayer = null

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

func safe_play(playlist: Dictionary, state: String, is_last_chance: bool):
	if player == null:
		print_debug("AudioStreamPlayer is not assigned")
		return

	if state not in playlist:
		print_debug("Cannot find sound for state '%s'" % state)
		return

	var sound: SoundData = playlist[state]
	if sound:
		sound.play(player, is_last_chance)


func _on_player_dash(_player: Player, state: String, is_last_chance: bool):
	safe_play(playlists[Playlists.Dash], state, is_last_chance)


func _on_player_jump(_player: Player, state: String, is_last_chance: bool):
	safe_play(playlists[Playlists.Jump], state, is_last_chance)
