# EnemyOrb.gd
extends Area2D

# --- Konfigurovatelné proměnné ---
@export var is_horizontal : bool = true   # true = horizontální pohyb, false = vertikální pohyb
@export var is_static : bool = false      # true = nepřítel se nepohybuje
@export var move_distance : float = 50 # vzdálenost pohybu
@export var speed : float = 100.0         # rychlost pohybu

# --- Interní proměnné ---
var start_position : Vector2
var moving_forward : bool = true
var velocity = Vector2.ZERO


func _ready():
	start_position = global_position

func _physics_process(delta):
	if is_static:
		velocity = Vector2.ZERO
		return

	var target_position : Vector2

	if is_horizontal:
		if moving_forward:
			target_position = start_position + Vector2(move_distance, 0)
			velocity.x = target_position.x - global_position.x
			velocity.y = 0
		else:
			target_position = start_position + Vector2(0, 0)
			velocity.x = target_position.x - global_position.x
			velocity.y = 0
			
	elif !is_horizontal:
		if moving_forward:
			target_position = start_position + Vector2(0, move_distance)
			velocity.y = target_position.y - global_position.y
			velocity.x = 0
		else:
			target_position = start_position + Vector2(0, 0)
			velocity.y = target_position.y - global_position.y
			velocity.x = 0

	# Normalizuj a násob rychlostí
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	
	global_position += velocity * delta

	# Kontrola, zda jsme dorazili k cíli
	if global_position.distance_to(target_position) < 1.0:
		moving_forward = !moving_forward
