extends Node2D

@export var rotation_speed = 2.0

func _process(delta):
	# Rotate continuously
	rotation += rotation_speed * delta
