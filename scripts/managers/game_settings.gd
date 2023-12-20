extends Node

signal config_loaded(config_name: String)

const CONFIG_LIST_PATH: String = "user://game_settings/config_list.cfg"
const CONFIG_DIRECTORY: String = "user://game_settings"
const CONFIG_FILE_EXTENSION: String = ".cfg"

var CONFIG_PATH_PATTERN: String = "%s/%s%s" % [CONFIG_DIRECTORY, "%s", CONFIG_FILE_EXTENSION]
var saving: bool = false

var configs: Dictionary = {
	"graphics": ConfigFile.new(),
	"audio":    ConfigFile.new(),
}

func _ready() -> void:
	load_configs()

func get_config(config_name: String) -> ConfigFile:
	if not configs.has(config_name):
		configs[config_name] = ConfigFile.new()
	return configs[config_name]

func load_configs() -> void:
	_ensure_directory_exists(CONFIG_DIRECTORY)
	_load_config_list()

	for config_name: String in configs.keys():
		var config_path: String = CONFIG_PATH_PATTERN % config_name
		if FileAccess.file_exists(config_path):
			get_config(config_name).load(config_path)
			emit_signal("config_loaded", config_name)
	print("[GameSettings] configs loaded")

func save_configs() -> void:
	if saving: return

	saving = true
	await get_tree().create_timer(0.5).timeout

	_ensure_directory_exists(CONFIG_DIRECTORY)
	_store_config_list()

	for config_name: String in configs.keys():
		var config_path: String = CONFIG_PATH_PATTERN % config_name
		configs[config_name].save(config_path)

	saving = false

func _ensure_directory_exists(directory: String) -> void:
	if not DirAccess.dir_exists_absolute(directory):
		DirAccess.make_dir_recursive_absolute(directory)

func _load_config_list() -> void:
	if FileAccess.file_exists(CONFIG_LIST_PATH):
		for config: String in FileAccess.get_file_as_string(CONFIG_LIST_PATH).split('\n'):
			if config in configs.keys():
				continue

			configs[config] = ConfigFile.new()

func _store_config_list() -> void:
	var content: String = ""
	for config: String in configs.keys():
		content += config + '\n'

	var file: FileAccess = FileAccess.open(CONFIG_LIST_PATH, FileAccess.WRITE)
	file.store_string(content)
	file.close()
