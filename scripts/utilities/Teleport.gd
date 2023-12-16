class_name Teleport extends Node2D

@export var destination: Vector2

func teleport(body: Node2D):
	body.position = destination
