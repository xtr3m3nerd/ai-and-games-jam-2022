extends Node

var idle_music = load("res://sounds/music/spooky-carving.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_music():
	$Music.stream = idle_music
	$Music.play()
