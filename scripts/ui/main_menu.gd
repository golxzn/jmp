class_name MainMenu extends Control

signal play_button_pressed
signal exit_button_pressed

signal main_menu_show_animation_complete
signal settings_show_animation_complete

@onready var animations: AnimationPlayer = %AnimationPlayer
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var version_label: Label = %VersionLabel

@onready var vignetting: Vingetting = %VignettingEffect

@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton

@onready var audio_button: Button = %AudioButton
@onready var graphics_button: Button = %GraphicsButton
@onready var input_button: Button = %InputButton
@onready var back_button: Button = %BackButton

@onready var audio_settings_grid: GridContainer = %AudioSettingsGrid
@onready var graphics_settings_grid: GridContainer = %GraphicsSettingsGrid
@onready var input_settings_grid: GridContainer = %InputSettingsGrid

func _ready():
	_setup_version_label()
	_set_main_buttons_disabled(false)
	_set_settings_buttons_disabled(true)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if Focus.event_is_action_released(event, "ui_cancel"):
		if is_in_settings():
			show_menu()

func is_in_settings() -> bool:
	return input_settings_grid.visible or graphics_settings_grid.visible or audio_settings_grid.visible

#region Show / Hide main menu

func show_menu():
	set_process_input(true)
	_clear_main_buttons_focus()
	_clear_settings_buttons_focus()
	_set_settings_buttons_disabled(true)

	if not vignetting.visible:
		vignetting.appear()
	animation_playback.travel("show_main")

	await animation_tree.animation_finished
	_set_main_buttons_disabled(false)
	play_button.grab_focus()
	main_menu_show_animation_complete.emit()

func exit_menu():
	set_process_input(false)
	_clear_main_buttons_focus()
	_set_main_buttons_disabled(true)
	_set_settings_buttons_disabled(true)

	if vignetting.visible:
		vignetting.disappear()
	animation_playback.travel("hide_main")

	await animation_tree.animation_finished

#endregion Show / Hide main menu

#region Show / Hide settings

func show_settings():
	set_process_input(true)
	_set_main_buttons_disabled(true)

	animation_playback.travel("show_settings")

	await animation_tree.animation_finished
	_set_settings_buttons_disabled(false)
	audio_button.grab_focus()
	settings_show_animation_complete.emit()

#endregion Show / Hide settings

#region Buttons callbacks

func _on_play_button_pressed():
	play_button_pressed.emit()


func _on_settings_button_pressed():
	show_settings()


func _on_exit_button_pressed():
	exit_button_pressed.emit()



func _on_audio_button_pressed() -> void:
	if audio_settings_grid.visible: return

	input_settings_grid.visible = false
	graphics_settings_grid.visible = false
	audio_settings_grid.visible = true

func _on_graphics_button_pressed() -> void:
	if graphics_settings_grid.visible: return

	input_settings_grid.visible = false
	audio_settings_grid.visible = false
	graphics_settings_grid.visible = true

func _on_input_button_pressed() -> void:
	if input_settings_grid.visible: return

	audio_settings_grid.visible = false
	graphics_settings_grid.visible = false
	input_settings_grid.visible = true

func _on_back_button_pressed() -> void:
	show_menu()

#endregion

#region utilities

func _setup_version_label():
	var version: Variant = ProjectSettings.get_setting("application/config/version")
	if version == null: version = "v0.0.0.0"
	else: version = "v" + str(version)

	version_label.text = version

func _set_main_buttons_disabled(value: bool):
	play_button.disabled = value
	settings_button.disabled = value
	exit_button.disabled = value

func _clear_main_buttons_focus():
	play_button.release_focus()
	settings_button.release_focus()
	exit_button.release_focus()


func _set_settings_buttons_disabled(value: bool):
	audio_button.disabled = value
	graphics_button.disabled = value
	input_button.disabled = value
	back_button.disabled = value

func _clear_settings_buttons_focus():
	audio_button.release_focus()
	graphics_button.release_focus()
	input_button.release_focus()
	back_button.release_focus()

#endregion
