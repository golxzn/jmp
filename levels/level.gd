class_name Level extends Node2D

@export_group("Player settings")
@export var player: Player = null

@export_group("Camera settings")
@export var camera: Camera2D = null

func _ready():
	assert(player != null, "You need to set the player in the editor for '%s' level" % name)
