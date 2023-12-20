class_name AudioSettingsGrid extends GridContainer

const VOLUME_PATH: String = "audio/bus_volume_db/volume/%s"
const MIN_VOLUME: float = linear_to_db(0.0)
const MAX_VOLUME: float = linear_to_db(1.0)

@onready var music_value_label: Label = %MusicSliderValue
@onready var player_sfx_value_label: Label = %PlayerSFXValue
@onready var environment_sfx_value_label: Label = %EnvironmentSFXValue
@onready var interface_sfx_value_label: Label = %InterfaceSFXValue

@onready var music_bus_id: int           = AudioServer.get_bus_index("music")
@onready var player_sfx_bus_id: int      = AudioServer.get_bus_index("player_sfx")
@onready var environment_sfx_bus_id: int = AudioServer.get_bus_index("environment_sfx")
@onready var interface_sfx_bus_id: int   = AudioServer.get_bus_index("UI")

func _ready() -> void:
	_load_config()

func _update_all_labels() -> void:
	_update_label(music_value_label, db_to_linear(AudioServer.get_bus_volume_db(music_bus_id)))
	_update_label(player_sfx_value_label, db_to_linear(AudioServer.get_bus_volume_db(player_sfx_bus_id)))
	_update_label(environment_sfx_value_label, db_to_linear(AudioServer.get_bus_volume_db(environment_sfx_bus_id)))
	_update_label(interface_sfx_value_label, db_to_linear(AudioServer.get_bus_volume_db(interface_sfx_bus_id)))

func _update_label(label: Label, value: float) -> void:
	label.text = "%d%%" % int(clamp(value, 0, 1.0) * 100.0)

func _set_sound_value(label: Label, id: int, value: float) -> void:
	_update_label(label, db_to_linear(value))
	AudioServer.set_bus_volume_db(id, value)
	AudioServer.set_bus_mute(id, value == MIN_VOLUME)

func _on_music_slider_value_changed(value: float) -> void:
	var db_volume: float = linear_to_db(value)
	_set_sound_value(music_value_label, music_bus_id, db_volume)
	ProjectSettings.set_setting(VOLUME_PATH % "music", db_volume)

func _on_player_sfx_slider_value_changed(value: float) -> void:
	var db_volume: float = linear_to_db(value)
	_set_sound_value(player_sfx_value_label, player_sfx_bus_id, db_volume)
	ProjectSettings.set_setting(VOLUME_PATH % "player_sfx", db_volume)

func _on_environment_sfx_slider_value_changed(value: float) -> void:
	var db_volume: float = linear_to_db(value)
	_set_sound_value(environment_sfx_value_label, environment_sfx_bus_id, db_volume)
	ProjectSettings.set_setting(VOLUME_PATH % "environment_sfx", db_volume)

func _on_interface_sfx_slider_value_changed(value: float) -> void:
	var db_volume: float = linear_to_db(value)
	_set_sound_value(interface_sfx_value_label, interface_sfx_bus_id, db_volume)
	ProjectSettings.set_setting(VOLUME_PATH % "interface_sfx", db_volume)


func _load_config() -> void:
	var music_value: float = ProjectSettings.get_setting(VOLUME_PATH % "music", MAX_VOLUME)
	var player_sfx_value: float = ProjectSettings.get_setting(VOLUME_PATH % "player_sfx", MAX_VOLUME)
	var environment_sfx_value: float = ProjectSettings.get_setting(VOLUME_PATH % "environment_sfx", MAX_VOLUME)
	var interface_sfx_value: float = ProjectSettings.get_setting(VOLUME_PATH % "interface_sfx", MAX_VOLUME)

	_set_sound_value(music_value_label, music_bus_id, music_value)
	$MusicSlider.value = db_to_linear(music_value)

	_set_sound_value(player_sfx_value_label, player_sfx_bus_id, player_sfx_value)
	$PlayerSFXSlider.value = db_to_linear(player_sfx_value)

	_set_sound_value(environment_sfx_value_label, environment_sfx_bus_id, environment_sfx_value)
	$EnvironmentSFXSlider.value = db_to_linear(environment_sfx_value)

	_set_sound_value(interface_sfx_value_label, interface_sfx_bus_id, interface_sfx_value)
	$InterfaceSFXSlider.value = db_to_linear(interface_sfx_value)

