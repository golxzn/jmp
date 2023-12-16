class_name MainMenu extends CanvasLayer

signal play_button_pressed
signal exit_button_pressed

class Animations:
	const VignettingIn  = "vignetting_in"
	const VignettingOut = "vignetting_out"

@onready var animations: AnimationPlayer = %AnimationPlayer
@onready var version_label: Label = %VersionLabel

func _ready():
	_setup_version_label()

	animations.play(Animations.VignettingIn)

func start_game():
	animations.play(Animations.VignettingOut)


func _setup_version_label():
	var version: Variant = ProjectSettings.get_setting("application/config/version")
	if version == null: version = "v0.0.0.0"
	else: version = "v" + str(version)

	version_label.text = version


func _on_play_button_pressed():
	play_button_pressed.emit()


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_exit_button_pressed():
	exit_button_pressed.emit()

