class_name Main extends Node

@export_group("Interface")
@export var main_menu_scene: PackedScene = preload("res://interfaces/main_menu.tscn")
@export var main_menu_place: Node = null

@export_group("Game")
@export var game_default_scene: PackedScene = preload("res://levels/playground/playground.tscn")
@export var game_place: Node = null

@onready var main_camera = %MainCam

var current_level: Level = null
var main_menu: MainMenu = null

func _ready():
	# assert(main_menu_place != null, "Cannot found main_menu_place node")
	assert(game_place != null, "Cannot found game_place node")

	get_tree().paused = true

	_load_last_game()
	_load_main_menu()
	_setup_camera()

func _load_last_game():
	assert(game_default_scene != null, "Cannot found game_default_scene resource file")
	assert(game_default_scene.can_instantiate(), "Cannot instantiate game_default_scene resource file")

	var scene: Level = game_default_scene.instantiate()
	assert(scene != null, "Cannot instantiate game_default_scene resource file. Scene type is %s" % typeof(scene))
	game_place.add_child(scene)

	current_level = scene

func _load_main_menu():
	assert(main_menu_scene != null, "Cannot found main_menu_scene resource file")
	assert(main_menu_scene.can_instantiate(), "Cannot instantiate main_menu_scene resource file")

	# var display: Node = current_level.player.find_child("Display")
	# assert(display != null, "Cannot found player's display node")
	# display.add_child(main_menu_scene.instantiate())
	if main_menu == null:
		main_menu = main_menu_scene.instantiate()
	else:
		main_menu.enabled = true

	main_menu.play_button_pressed.connect(self._on_play_button_pressed)
	main_menu.exit_button_pressed.connect(self._on_exit_button_pressed)
	main_menu_place.add_child(main_menu)

func _unload_main_menu():
	if main_menu != null:
		main_menu.play_button_pressed.disconnect(self._on_play_button_pressed)
		main_menu.exit_button_pressed.disconnect(self._on_exit_button_pressed)
		main_menu_place.remove_child(main_menu)

func _setup_camera():
	assert(current_level != null, "Cannot setup camera: current_level is null")

	var cam: Camera2D = get_viewport().get_camera_2d()
	if cam: current_level.player.remote_transform.remote_path = cam.get_path()


func _on_play_button_pressed():
	_unload_main_menu()

	main_camera.enabled = false

	current_level.camera.enabled = true
	current_level.camera.make_current()

	_setup_camera()
	get_tree().paused = false

func _on_exit_button_pressed():
	get_tree().quit()
