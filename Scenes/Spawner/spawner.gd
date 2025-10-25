extends Node2D

@export var item_scene: PackedScene
@export var spawn_marker: Marker2D
@export var auto_spawn: bool = false
@export var spawn_interval: float = 2.0
var spawn_timer: float = 0.0

func _ready():
	# Try to find a spawn marker if none is assigned
	if spawn_marker == null:
		for child in get_children():
			if child is Marker2D:
				spawn_marker = child
				break
	
	# Warn if no marker found
	if spawn_marker == null:
		push_warning("No spawn marker assigned or found!")

func _process(delta):
	# Handle automatic spawning
	if auto_spawn and item_scene != null and spawn_marker != null:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_item()
			spawn_timer = 0.0

func spawn_item():
	# Check if item scene exists
	if item_scene == null:
		push_error("No item scene assigned!")
		return
	
	# Check if spawn marker exists
	if spawn_marker == null:
		push_error("No spawn marker assigned!")
		return
	
	# Create the item
	var item = item_scene.instantiate()
	
	# Set spawn position
	item.global_position = spawn_marker.global_position
	
	# Add to scene
	get_parent().add_child(item)
	
	return item

func spawn_item_manual():
	# Manually spawn an item
	return spawn_item()
