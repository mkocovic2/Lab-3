extends CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D
# How fast the player moves
@export var speed: float = 200.0
# Track the current animation to avoid restarting it
var current_animation: String = ""

func _physics_process(delta):
	# Start with no movement
	var input_vector = Vector2.ZERO
	
	# Check left/right input
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Check up/down input
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Make sure diagonal movement isn't faster than straight
	input_vector = input_vector.normalized()
	# Figure out final velocity
	velocity = input_vector * speed
	
	# Move the player and handle collisions
	move_and_slide()
	
	# Update animation based on movement
	update_appearance()
	
func update_appearance():
	"""Change animation based on state"""
	if not animated_sprite:
		return
	
	# Check if we're moving
	var is_moving = velocity.length() > 10.0 
	
	# Determine the desired animation
	var desired_animation: String = ""
	
	if velocity.y < -10.0:
		# Moving up
		desired_animation = "idle_up"
	elif velocity.y > 10.0:
		# Moving down
		desired_animation = "idle_down"
	elif is_moving:
		# Moving horizontally
		desired_animation = "walk"
	else:
		# Not moving
		desired_animation = "idle"
	
	# Only change animation if it's different from current
	if desired_animation != current_animation:
		current_animation = desired_animation
		animated_sprite.animation = desired_animation
		animated_sprite.play()
	
	# Face the direction we're moving
	if velocity.x < 0:
		animated_sprite.flip_h = false
	elif velocity.x > 0:
		animated_sprite.flip_h = true
