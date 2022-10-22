extends Node

var button_sound = load("res://assets/sounds/sfx/Blip_select 25.wav")

func play_button():
	$Button.stream = button_sound
	$Button.play()
