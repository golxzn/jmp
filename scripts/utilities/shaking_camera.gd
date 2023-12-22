class_name ShakingCamera extends Camera2D

@export var noise: FastNoiseLite
@export var noise_shake_speed: float = 30.0
@export var noise_shake_strength: float = 60.0
@export var shake_decay_rate: float = 5.0

@onready var vsh_glitch: ColorRect = $VSHGlitch

var noise_y: float = 0.0
var shake_strenght: float = 0.0

func _ready() -> void:
	assert(noise != null, "Noise must be present")
	var rand: RandomNumberGenerator = RandomNumberGenerator.new()
	rand.randomize()

	noise.seed = rand.randi()

func _process(delta: float) -> void:
	shake_strenght = lerp(shake_strenght, 0.0, delta * shake_decay_rate)
	offset = get_noise_offset(delta, shake_strenght)

func enable_glitches() -> void:
	vsh_glitch.visible = true

func disable_glitches() -> void:
	vsh_glitch.visible = false

func apply_shake(strenght: float = noise_shake_strength) -> void:
	shake_strenght = min(strenght, noise_shake_strength)

func get_noise_offset(delta: float, streight: float) -> Vector2:
	noise_y += delta * noise_shake_speed
	return Vector2(
		noise.get_noise_2d(  1, noise_y) * streight,
		noise.get_noise_2d(100, noise_y) * streight
	)
