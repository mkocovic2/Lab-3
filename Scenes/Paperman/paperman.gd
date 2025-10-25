extends Area2D

var player: Node2D
@export var follow_speed: float = 200.0
@export var damage: int = 10
@export var damage_cooldown: float = 1.0
var can_damage: bool = true
var damage_timer: float = 0.0
@export var enemy_health: int = 30
var is_dead: bool = false
@export var knockback_strength: float = 300.0
var knockback_velocity: Vector2 = Vector2.ZERO
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	# Find the player in the scene
	player = get_tree().root.find_child("Player", true, false)
	
	# Connect collision signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta):
	# Don't do anything if dead or player doesn't exist
	if is_dead or not player:
		return
	
	# Handle damage cooldown timer
	if not can_damage:
		damage_timer -= delta
		if damage_timer <= 0:
			can_damage = true
	
	# Apply knockback if moving
	if knockback_velocity.length() > 5:
		global_position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 2 * delta)
	else:
		# Follow the player
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * follow_speed * delta

func _on_body_entered(body):
	# Handle collision with player body
	if body.name == "Player" and body.has_method("take_damage"):
		damage_player(body)

func _on_area_entered(area):
	# Handle collision with player's hitbox area
	var body = area.get_parent()
	if body and body.name == "Player" and body.has_method("take_damage"):
		damage_player(body)

func damage_player(player_node):
	# Deal damage to the player
	if can_damage and not is_dead:
		player_node.take_damage(damage)
		can_damage = false
		damage_timer = damage_cooldown
		
		# Push player away
		apply_knockback_to_player(player_node)

func apply_knockback_to_player(player_node):
	# Push the player away when hit
	if player_node.has_method("apply_knockback"):
		var knockback_direction = (player_node.global_position - global_position).normalized()
		player_node.apply_knockback(knockback_direction, 300.0)

func take_damage(amount: int, attacker_position: Vector2 = global_position):
	# Allow the enemy to take damage from player attacks
	if is_dead:
		return
	
	# Reduce health
	enemy_health -= amount
	# Play hit sound
	audio_player.stream = load("res://Assets/Audio/Enemyhit.mp3")
	audio_player.play()
	
	# Apply knockback away from attacker
	var knockback_direction = (global_position - attacker_position).normalized()
	knockback_velocity = knockback_direction * knockback_strength
	
	# Flash red when hit
	flash_damage()
	
	# Die if health is zero or below
	if enemy_health <= 0:
		die()

func flash_damage():
	# Visual feedback when taking damage
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func die():
	# Handle enemy death
	is_dead = true
	
	# Fade out and destroy
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func get_health_percentage() -> float:
	# Returns enemy health as percentage
	return float(enemy_health) / 30.0
