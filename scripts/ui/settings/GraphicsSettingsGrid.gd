class_name GraphicsSettingsGrid extends GridContainer

const WINDOW_MODE_PATH: String = "display/window/size/mode"
const CONFIG_NAME: String = "graphics"

@onready var fullscreen_button: CheckButton = $FullscreenButton

func _ready() -> void:
	_load_config()

func _window_mode_to_boolean(mode: DisplayServer.WindowMode) -> bool:
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN: return true
	return false

func _boolean_to_window_mode(mode: bool) -> DisplayServer.WindowMode:
	if mode: return DisplayServer.WINDOW_MODE_FULLSCREEN
	return DisplayServer.WINDOW_MODE_WINDOWED


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	var mode: DisplayServer.WindowMode = _boolean_to_window_mode(toggled_on)
	DisplayServer.window_set_mode(mode)
	ProjectSettings.set_setting(WINDOW_MODE_PATH, mode)


func _load_config() -> void:
	var window_mode: DisplayServer.WindowMode = ProjectSettings.get_setting(WINDOW_MODE_PATH, DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen_button.button_pressed = _boolean_to_window_mode(window_mode)
	DisplayServer.window_set_mode(window_mode)
