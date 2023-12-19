class_name MainMenu extends Control

signal play_button_pressed
signal exit_button_pressed

signal main_menu_show_animation_complete
signal main_menu_hide_animation_complete


class Animations:
	const ShowMainMenu = "show_menu"
	const HideMainMenu = "hide_menu"

@onready var animations: AnimationPlayer = %AnimationPlayer
@onready var version_label: Label = %VersionLabel

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton

func _ready():
	_setup_version_label()
	_set_buttons_disabled(false)

#region Show / Hide main menu

func show_menu():
	if animations.is_playing(): await animations.animation_finished
	play_button.grab_focus()
	set_process_input(true)

	animations.play(Animations.ShowMainMenu)
	await animations.animation_finished
	main_menu_show_animation_complete.emit()
	_set_buttons_disabled(false)

func hide_menu():
	if animations.is_playing(): await animations.animation_finished
	play_button.release_focus()
	settings_button.release_focus()
	exit_button.release_focus()
	set_process_input(false)

	_set_buttons_disabled(true)
	animations.play(Animations.HideMainMenu)
	await animations.animation_finished
	main_menu_hide_animation_complete.emit()

#endregion Show / Hide main menu

#region Buttons callbacks

func _on_play_button_pressed():
	play_button_pressed.emit()


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_exit_button_pressed():
	exit_button_pressed.emit()

#endregion

#region utilities

func _setup_version_label():
	var version: Variant = ProjectSettings.get_setting("application/config/version")
	if version == null: version = "v0.0.0.0"
	else: version = "v" + str(version)

	version_label.text = version

func _set_buttons_disabled(value: bool):
	play_button.disabled = value
	settings_button.disabled = value
	exit_button.disabled = value

#endregion
