extends Area2D

# Reference to the player node
var player: Node2D
# How fast the object follows the player
@export var follow_speed: float = 200.0

func _ready():
	# Find the player node in the scene
	player = get_tree().root.find_child("Player", true, false)

func _process(delta):
	if not player:
		return
	
	# Get direction from this object to the player
	var direction = (player.global_position - global_position).normalized()
	
	# Move towards the player
	global_position += direction * follow_speed * delta
