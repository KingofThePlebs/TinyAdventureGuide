extends Area2D


var time_accumulator: float = 0.0

@export var next_level:  = "res://Components/World/world.tscn"

func _ready() -> void:
	GameLogicAL.key_grabbed = false

func new_level():
	$Door_Sound.play()
	await get_tree().create_timer(1.02).timeout
	get_tree().call_deferred("change_scene_to_file", next_level)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and GameLogicAL.key_grabbed >= GameLogicAL.required_keys:
		new_level()
	else:
		$Info2.show()
		
func _process(delta: float):
	# delta = kolik sekund uplynulo od posledního frame
	time_accumulator += delta
	
	if time_accumulator >= 1.0:
		$TextureProgressBar.value -= 1
		time_accumulator -= 1.0  # odečti 1s (pro přesnost při různém FPS)
	if $TextureProgressBar.value <= 0:
		GameLogicAL.restart_game()
		
