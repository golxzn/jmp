class_name Main extends Node

signal on_game_started()

@export_group("Interface")
@export var main_menu_scene: PackedScene = preload("res://scenes/ui/main_menu.tscn")
@export var main_menu_place: Node = null

@export_group("Game")
@export var game_default_scene: PackedScene = preload("res://scenes/levels/playground/playground.tscn")
@export var game_place: Node = null

# @onready var main_camera = %MainCam

var game_started: bool = false
var current_level: Level = null
var main_menu: MainMenu = null

func _ready():
	# ProjectSettings.save_custom("user://settings.binary")
	# assert(main_menu_place != null, "Cannot found main_menu_place node")
	assert(game_place != null, "Cannot found game_place node")

	get_tree().paused = true

	_load_last_game()
	_load_main_menu()
	# _setup_camera(main_camera)

	await main_menu.show_menu()

func _input(event: InputEvent) -> void:
	if Focus.event_is_action_released(event, "ui_pause") and game_started:
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			main_menu.show_menu()
		else:
			main_menu.exit_menu()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			if not get_tree().paused:
				get_tree().paused = true
				main_menu.show_menu()

		NOTIFICATION_WM_CLOSE_REQUEST:
			var path: String = ProjectSettings.get_setting("application/config/project_settings_override")
			if not DirAccess.dir_exists_absolute(path.get_base_dir()):
				DirAccess.make_dir_recursive_absolute(path.get_base_dir())
			ProjectSettings.save_custom(path)
			get_tree().quit()

func _load_last_game():
	assert(game_default_scene != null, "Cannot found game_default_scene resource file")
	assert(game_default_scene.can_instantiate(), "Cannot instantiate game_default_scene resource file")

	current_level = game_default_scene.instantiate()
	assert(current_level != null, "Cannot instantiate game_default_scene resource file. Scene type is %s" % current_level)
	game_place.add_child(current_level)


func _load_main_menu():
	assert(main_menu_scene != null, "Cannot found main_menu_scene resource file")
	assert(main_menu_scene.can_instantiate(), "Cannot instantiate main_menu_scene resource file")

	if main_menu == null:
		main_menu = main_menu_scene.instantiate()
		main_menu.play_button_pressed.connect(self._on_play_button_pressed)
		main_menu.exit_button_pressed.connect(self._on_exit_button_pressed)
		main_menu_place.add_child(main_menu)

func _setup_camera(camera: Camera2D):
	assert(current_level != null, "Cannot setup camera: current_level is null")

	var previous_camera: Camera2D = get_viewport().get_camera_2d()
	if previous_camera != null:
		previous_camera.enabled = false

	camera.enabled = true
	camera.make_current()

func _on_play_button_pressed():
	main_menu.exit_menu()

	_setup_camera(current_level.camera)
	get_tree().paused = false
	game_started = true
	on_game_started.emit()


func _on_exit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	await main_menu.exit_menu()
