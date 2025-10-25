extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D

@export var speed: float = 200.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5

@onready var health_label = $"Player UI/Health"
@export var max_health: int = 100
@export var invincibility_duration: float = 1.0
var current_health: int
var is_invincible: bool = false
var invincibility_timer: float = 0.0

var is_dashing: bool = false
var can_dash: bool = true
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var current_animation: String = ""

signal health_changed(new_health, max_health)
signal died()
signal took_damage(damage_amount)

func _ready():
	# Set health to max
	current_health = max_health
	health_label.text = "Health: " + str(current_health)
	health_changed.emit(current_health, max_health)

func _physics_process(delta):
	# Handle invincibility frames
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false
			animated_sprite.modulate.a = 1.0  # Reset transparency
		else:
			# Flashing effect
			var flash = abs(sin(invincibility_timer * 20.0))
			animated_sprite.modulate.a = 0.3 + (flash * 0.7)
	
	# Handle dash cooldown
	if not can_dash:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_dash = true
	
	# Handle dashing
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			can_dash = false
			cooldown_timer = dash_cooldown
		else:
			# Move in dash direction
			velocity = dash_direction * dash_speed
			move_and_slide()
			return
	
	# Get player input
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	
	# Start dash if space is pressed and dash is available
	if Input.is_action_pressed("ui_select") and can_dash and input_vector != Vector2.ZERO:
		is_dashing = true
		audio_player.stream = load("res://Assets/Audio/Dash.mp3")
		audio_player.play()
		dash_timer = dash_duration
		dash_direction = input_vector
		velocity = dash_direction * dash_speed
	else:
		# Normal movement
		velocity = input_vector * speed
	
	move_and_slide()

	# Update animation and sprite direction
	update_appearance()

func update_appearance():
	# Change animation based on state
	if not animated_sprite:
		return
	
	# Force damaged animation when invincible
	if is_invincible:
		var desired_animation = "damaged"
		if desired_animation != current_animation:
			current_animation = desired_animation
			animated_sprite.animation = desired_animation
			animated_sprite.play()
		
		# Still flip sprite based on movement
		if velocity.x < 0:
			animated_sprite.flip_h = false
		elif velocity.x > 0:
			animated_sprite.flip_h = true
		return
	
	var is_moving = velocity.length() > 10.0 
	
	var desired_animation: String = ""
	
	# Choose animation based on movement direction
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

func take_damage(damage: int) -> void:
	# Deal damage to the player
	if is_invincible or current_health <= 0:
		return
	
	# Reduce health
	current_health = max(0, current_health - damage)
	health_label.text = "Health: " + str(current_health)
	took_damage.emit(damage)
	health_changed.emit(current_health, max_health)
	
	# Activate invincibility frames
	is_invincible = true
	invincibility_timer = invincibility_duration
	
	# Check if player died
	if current_health <= 0:
		die()

func die() -> void:
	# Handle player death
	died.emit()

	set_physics_process(false)	
	
	# Show death message and restart
	$"Player UI/Death Message".show()
	
	animated_sprite.play("damaged")
	await get_tree().create_timer(1.0).timeout  
	get_tree().reload_current_scene()

	set_physics_process(false)

func get_health_percentage() -> float:
	# Returns health as a percentage
	return float(current_health) / float(max_health)

func is_alive() -> bool:
	# Check if player is still alive
	return current_health > 0

func reset_health() -> void:
	# Reset health to maximum
	current_health = max_health
	is_invincible = false
	health_changed.emit(current_health, max_health)
	set_physics_process(true)
