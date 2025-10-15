extends Node2D

@export var rotation_speed = 2.0

func _process(delta):
	rotation += rotation_speed * delta
