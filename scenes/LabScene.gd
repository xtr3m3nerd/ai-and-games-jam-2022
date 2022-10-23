extends Spatial

export var arena_scene: String = "res://scenes/ArenaScene.tscn"
onready var player = $Player
onready var action_text = $UI/ActionText

var is_at_exit = false
var is_at_computer = false
var is_at_upgrades = false

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.transition_music(MusicManager.MUSIC.LAB)
	action_text.hide()

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if is_at_exit:
			SceneManager.set_current_scene(arena_scene)
		if is_at_computer:
			print("Accessed Computer")
		if is_at_upgrades:
			print("Accessed Upgrades")


func _on_ExitArea_body_entered(body):
	if body == player:
		is_at_exit = true
		action_text.text = "Press 'E' to go to arena"
		action_text.show()


func _on_ExitArea_body_exited(body):
	if body == player:
		is_at_exit = false
		action_text.hide()


func _on_ComputerArea_body_entered(body):
	if body == player:
		is_at_computer = true
		action_text.text = "Press 'E' to use computer"
		action_text.show()


func _on_ComputerArea_body_exited(body):
	if body == player:
		is_at_computer = false
		action_text.hide()


func _on_UpgradeArea_body_entered(body):
	if body == player:
		is_at_upgrades = true
		action_text.text = "Press 'E' to manage upgrades"
		action_text.show()


func _on_UpgradeArea_body_exited(body):
	if body == player:
		is_at_upgrades = false
		action_text.hide()
