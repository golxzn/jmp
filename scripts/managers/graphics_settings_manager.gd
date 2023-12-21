extends Node

const WINDOW_MODE_PATH: String = "display/window/size/mode"

func _ready() -> void:
	pass
	# var current_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	# var mode_in_settings: DisplayServer.WindowMode = ProjectSettings.get_setting(WINDOW_MODE_PATH, current_mode)
	# if mode_in_settings != current_mode:
	# 	DisplayServer.window_set_mode(mode_in_settings)

func get_window_fullscreen() -> bool:
	return _window_mode_to_boolean(DisplayServer.window_get_mode())

func set_window_fullscreen(fullscreen: bool) -> void:
	var mode: DisplayServer.WindowMode = _boolean_to_window_mode(fullscreen)
	DisplayServer.window_set_mode(mode)
	ProjectSettings.set_setting(WINDOW_MODE_PATH, mode)

func _window_mode_to_boolean(mode: DisplayServer.WindowMode) -> bool:
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN: return true
	return false

func _boolean_to_window_mode(mode: bool) -> DisplayServer.WindowMode:
	if mode: return DisplayServer.WINDOW_MODE_FULLSCREEN
	return DisplayServer.WINDOW_MODE_WINDOWED

