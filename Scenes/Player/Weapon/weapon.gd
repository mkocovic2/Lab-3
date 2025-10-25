extends Area2D

@export var damage: int = 10

func _ready():
	# Connect collision signals
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area):
	# Deal damage to areas that can take it
	if area.has_method("take_damage"):
		area.take_damage(damage, global_position)

func _on_body_entered(body):
	# Deal damage to bodies that can take it
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
