extends Spatial

export var lab_scene: String = "res://scenes/LabScene.tscn"
onready var player = $Player
onready var action_text = $UI/ActionText

var is_at_exit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.transition_music(MusicManager.MUSIC.BATTLE)
	action_text.hide()

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if is_at_exit:
			SceneManager.set_current_scene(lab_scene)

func _on_LabEntrance_body_entered(body):
	if body == player:
		is_at_exit = true
		action_text.text = "Press 'E' to go to lab"
		action_text.show()


func _on_LabEntrance_body_exited(body):
	if body == player:
		is_at_exit = false
		action_text.hide()
