extends Node

var quit_popup: Resource = load("res://menus/QuitPopup.tscn")
var is_quiting = false

var player_data = {
	"hp": 10,
	"maxhp": 10,
	"speed": 10,
	"melee_damage": 5,
	"money": 25,
}

var available_upgrades = [
	{
		"name": "Repairs",
		"cost": 5,
		"amount": 5,
		"description": "Restore 5 HP",
		"stat": "hp",
		"image": "image_path",
		"persistant": true,
	},
	{
		"name": "Wheels",
		"cost": 5,
		"amount": 5,
		"description": "Increased Speed",
		"stat": "speed",
		"image": "image_path",
	},
	{
		"name": "Crow Bar",
		"cost": 5,
		"amount": 5,
		"description": "Increased Damage",
		"stat": "melee_damage",
		"image": "image_path",
	},
	{
		"name": "Sign Shield",
		"cost": 5,
		"amount": 5,
		"description": "Increased Defense",
		"stat": "blocking",
		"image": "image_path",
	},
	{
		"name": "Metal Chassis",
		"cost": 5,
		"amount": 10,
		"description": "Increase Max HP",
		"stat": "maxhp",
		"image": "image_path",
	},
]

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		quit_game()

func quit_game():
	if OS.get_name() == "Web":
		return
	if is_quiting:
		return
	is_quiting = true
	get_tree().get_root().add_child(quit_popup.instance())
