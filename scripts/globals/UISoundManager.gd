extends Node

var button_sound = load("res://assets/sounds/sfx/down_chime.wav")

func play_button():
	$Button.stream = button_sound
	$Button.play()
