class_name Vingetting extends ColorRect

signal vignetting_appearing_start
signal vignetting_appearing_finish

signal vignetting_disappearing_start
signal vignetting_disappearing_finish

class Animations:
	const Appearing: String    = "vignetting_appearing"
	const Disappearing: String = "vignetting_disappearing"

@onready var animations: AnimationPlayer = $AnimationPlayer


func appear():
	vignetting_appearing_start.emit()
	animations.play(Animations.Appearing)
	await animations.animation_finished
	vignetting_appearing_finish.emit()

func disappear():
	vignetting_disappearing_start.emit()
	animations.play(Animations.Disappearing)
	await animations.animation_finished
	vignetting_disappearing_finish.emit()

