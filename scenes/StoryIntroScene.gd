extends Node

enum STATE { INTRO1, INTRO2 }

var cur_state = STATE.INTRO1

export var lab_scene: String = "res://scenes/LabScene.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.transition_music(MusicManager.MUSIC.STORY)

func _process(_delta):
	
	if Input.is_action_just_pressed("jump"):
		change_state(cur_state + 1)

func change_state(new_state):
	match cur_state:
		STATE.INTRO1:
			$Intro1.hide()
		STATE.INTRO2:
			SceneManager.set_current_scene(lab_scene)
	
	match new_state:
		STATE.INTRO1:
			$Intro1.show()
		STATE.INTRO2:
			$Intro2.show()
	
	cur_state = new_state
