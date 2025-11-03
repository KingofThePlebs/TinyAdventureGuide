extends CharacterBody2D

# --- Editor variables ---
@export var move_speed: float = 40
@export var jump_velocity: float = -50
@export var max_extra_jumps: int = 1         # 1 = double jump, 2 = triple jump
@export var gravity: float = 200
@export var fall_multiplier: float = 3    
@export var jump_hold_time: float = 0.2  
@export var max_HP: int = 8  
@export var required_keys_player = 1

@onready var animation =  $AnimatedSprite2D
var turn_right = false
var idle = true

var HP: int



var extra_jumps_left: int
var jump_pressed_time: float = 0.0
var is_jumping: bool = false


func _ready():
	HP = max_HP
	extra_jumps_left = max_extra_jumps
	$HPbar.value = HP
	
	
	GameLogicAL.key_grabbed = 0
	GameLogicAL.required_keys = required_keys_player

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	do_hp()
	#Move
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
		turn_right = true
		if velocity.y == 0 and is_on_floor():
			animation.play("run")
			$Walk.emitting = true
		
	elif Input.is_action_pressed("move_left"):
		input_dir.x -= 1
		turn_right = false
		if velocity.y == 0 and is_on_floor():
			animation.play("run")
			$Walk.emitting = true
		
	else:
		if velocity.y == 0 and is_on_floor():
			animation.play("idle")
			$Walk.emitting = false
			
	
	velocity.x = input_dir.x * move_speed
	

	# --- Gravitace ---
	if velocity.y > 0:
		velocity.y += gravity * fall_multiplier * delta  # padání rychlejší
	else:
		velocity.y += gravity * delta  # normální gravitace

	# --- Skákání ---
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			do_jump()
			$Jump.emitting = true
			if turn_right == true:
				animation.play("jump_right")
			else:
				animation.play("jump_left")
			
		if extra_jumps_left > 0:
			do_jump()
			extra_jumps_left -= 1

	# --- Délka držení skoku ---
	if Input.is_action_pressed("jump") and is_jumping:
		jump_pressed_time += delta
		if jump_pressed_time < jump_hold_time:
			velocity.y = jump_velocity  # podržení zvyšuje výšku
	else:
		is_jumping = false

	# --- Reset skoků na zemi ---
	if is_on_floor():
		extra_jumps_left = max_extra_jumps

	move_and_slide()

func do_jump():
	velocity.y = jump_velocity
	jump_pressed_time = 0.0
	is_jumping = true
	$Jump_Sound.play()
	
func do_hp():
	$HPbar.value = HP
	
	if HP <= 0:
		GameLogicAL.restart_game()
		
func shrink():
	$Hitbox.monitorable = false
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self,"scale", Vector2(0,0), 1)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("danger"):
		$Hit_Sound.play()
		HP -= 2
		$HPparticles/Damage.text = str(2)
		$DamageTakenParticle.emitting = true
		
	elif area.is_in_group("lava"):
		$Hit_Sound.play()
		HP -= 9
		
	elif area.is_in_group("key"):
		$Key_Sound.play()
		GameLogicAL.key_grabbed += 1
		area.queue_free()
		
	elif area.is_in_group("heal_orb"):
		var HP_to_heal
		HP_to_heal = max_HP - HP
		HP += HP_to_heal
		area.queue_free()
		$Orbs_Sound.play()
	elif area.is_in_group("jump_orb"):
		max_extra_jumps += 1
		area.queue_free()
		$Orbs_Sound.play()
		
	elif area.is_in_group("speed_orb"):
		move_speed += 5
		area.queue_free()
		$Orbs_Sound.play()

	elif area.is_in_group("door") and GameLogicAL.key_grabbed == required_keys_player:
		shrink()
