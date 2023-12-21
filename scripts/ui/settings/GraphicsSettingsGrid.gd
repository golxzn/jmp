class_name GraphicsSettingsGrid extends GridContainer

@onready var fullscreen_button: CheckButton = $FullscreenButton

func _ready() -> void:
	fullscreen_button.button_pressed = GraphicsSettingsManager.get_window_fullscreen()

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	GraphicsSettingsManager.set_window_fullscreen(toggled_on)
