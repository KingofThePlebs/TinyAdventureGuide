extends Node2D

var key_grabbed: int = 0

var required_keys: int = 0

func restart_game():
	get_tree().reload_current_scene()
	
	
