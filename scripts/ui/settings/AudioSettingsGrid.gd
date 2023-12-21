class_name AudioSettingsGrid extends GridContainer

@onready var music_value_label: Label = %MusicSliderValue
@onready var player_sfx_value_label: Label = %PlayerSFXValue
@onready var environment_sfx_value_label: Label = %EnvironmentSFXValue
@onready var interface_sfx_value_label: Label = %InterfaceSFXValue

func _ready() -> void:
	_update_all_labels()
	_update_all_sliders()

func _update_all_labels() -> void:
	_update_label(music_value_label,           AudioSettingsManager.get_music_volume_linear())
	_update_label(player_sfx_value_label,      AudioSettingsManager.get_player_sfx_volume_linear())
	_update_label(environment_sfx_value_label, AudioSettingsManager.get_environment_sfx_volume_linear())
	_update_label(interface_sfx_value_label,   AudioSettingsManager.get_interface_sfx_volume_linear())

func _update_all_sliders() -> void:
	$MusicSlider.value =          AudioSettingsManager.get_music_volume_linear()
	$PlayerSFXSlider.value =      AudioSettingsManager.get_player_sfx_volume_linear()
	$EnvironmentSFXSlider.value = AudioSettingsManager.get_environment_sfx_volume_linear()
	$InterfaceSFXSlider.value =   AudioSettingsManager.get_interface_sfx_volume_linear()

func _update_label(label: Label, value: float) -> void:
	label.text = "%d%%" % int(clamp(value, 0, 1.0) * 100.0)

func _on_music_slider_value_changed(value: float) -> void:
	_update_label(music_value_label, value)
	AudioSettingsManager.set_music_volume_linear(value)

func _on_player_sfx_slider_value_changed(value: float) -> void:
	_update_label(player_sfx_value_label, value)
	AudioSettingsManager.set_player_sfx_volume_linear(value)

func _on_environment_sfx_slider_value_changed(value: float) -> void:
	_update_label(environment_sfx_value_label, value)
	AudioSettingsManager.set_environment_sfx_volume_linear(value)

func _on_interface_sfx_slider_value_changed(value: float) -> void:
	_update_label(interface_sfx_value_label, value)
	AudioSettingsManager.set_interface_sfx_volume_linear(value)
