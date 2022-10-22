extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.transition_music(MusicManager.MUSIC.STORY)
