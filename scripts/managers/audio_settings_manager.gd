extends Node

const VOLUME_PATH: String = "audio/bus_volume_db/volume/%s"
const MIN_VOLUME_LINEAR: float = 0.0
const MAX_VOLUME_LINEAR: float = 1.0
const MIN_VOLUME_DB: float = linear_to_db(MIN_VOLUME_LINEAR)
const MAX_VOLUME_DB: float = linear_to_db(MAX_VOLUME_LINEAR)

class Buses:
	const Music: String = "music"
	const PlayerSFX: String = "player_sfx"
	const EnvironmentSFX: String = "environment_sfx"
	const InterfaceSFX: String = "UI"

@onready var bus_indexes: Dictionary = {
	Buses.Music:          AudioServer.get_bus_index(Buses.Music),
	Buses.PlayerSFX:      AudioServer.get_bus_index(Buses.PlayerSFX),
	Buses.EnvironmentSFX: AudioServer.get_bus_index(Buses.EnvironmentSFX),
	Buses.InterfaceSFX:   AudioServer.get_bus_index(Buses.InterfaceSFX)
}

func _ready() -> void:
	for bus_name in bus_indexes.keys():
		set_volume_db(bus_name, get_volume_db(bus_name))

func get_volume_db(bus_name: String) -> float:
	return ProjectSettings.get_setting(VOLUME_PATH % bus_name, MAX_VOLUME_DB)

func get_volume_linear(bus_name: String) -> float:
	return db_to_linear(get_volume_db(bus_name))

func get_music_volume_db() -> float:           return get_volume_db(Buses.Music)
func get_player_sfx_volume_db() -> float:      return get_volume_db(Buses.PlayerSFX)
func get_environment_sfx_volume_db() -> float: return get_volume_db(Buses.EnvironmentSFX)
func get_interface_sfx_volume_db() -> float:   return get_volume_db(Buses.InterfaceSFX)

func get_music_volume_linear() -> float:           return get_volume_linear(Buses.Music)
func get_player_sfx_volume_linear() -> float:      return get_volume_linear(Buses.PlayerSFX)
func get_environment_sfx_volume_linear() -> float: return get_volume_linear(Buses.EnvironmentSFX)
func get_interface_sfx_volume_linear() -> float:   return get_volume_linear(Buses.InterfaceSFX)


func set_volume_db(bus_name: String, volume: float) -> void:
	if not bus_name in bus_indexes: return

	ProjectSettings.set_setting(VOLUME_PATH % bus_name, volume)
	AudioServer.set_bus_volume_db(bus_indexes[bus_name], volume)
	AudioServer.set_bus_mute(bus_indexes[bus_name], volume <= MIN_VOLUME_DB)

func set_volume_linear(bus_name: String, volume: float) -> void:
	set_volume_db(bus_name, linear_to_db(volume))

func set_music_volume_db(volume: float) -> void:           set_volume_db(Buses.Music, volume)
func set_player_sfx_volume_db(volume: float) -> void:      set_volume_db(Buses.PlayerSFX, volume)
func set_environment_sfx_volume_db(volume: float) -> void: set_volume_db(Buses.EnvironmentSFX, volume)
func set_interface_sfx_volume_db(volume: float) -> void:   set_volume_db(Buses.InterfaceSFX, volume)

func set_music_volume_linear(volume: float) -> void:           set_volume_linear(Buses.Music, volume)
func set_player_sfx_volume_linear(volume: float) -> void:      set_volume_linear(Buses.PlayerSFX, volume)
func set_environment_sfx_volume_linear(volume: float) -> void: set_volume_linear(Buses.EnvironmentSFX, volume)
func set_interface_sfx_volume_linear(volume: float) -> void:   set_volume_linear(Buses.InterfaceSFX, volume)