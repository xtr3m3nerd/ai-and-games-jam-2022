extends Node

var quit_popup: Resource = load("res://menus/QuitPopup.tscn")
var is_quiting = false

signal player_updated(_player_data)

func modify_player_data(key, value):
	player_data[key] = value
	emit_signal("player_updated", player_data)


var player_data = {
	"hp": 10,
	"maxhp": 10,
	"speed": 10,
	"melee_damage": 5,
	"money": 15,
	"applied_upgrades": []
}

var animal_genes = []

func _ready():
	populate_animal_genes(20)

func populate_animal_genes(amount):
	for n in amount: 
		animal_genes.append(Genes.generate_random_genes())

func apply_upgrade(upgrade):
	var index = available_upgrades.find(upgrade)
	if index == -1:
		return
	var persistant = upgrade.get("persistant", false)
	
	if !persistant:
		player_data["applied_upgrades"].append(upgrade)
		available_upgrades.remove(index)
	
	var player = get_tree().get_nodes_in_group("player")
	if player.size() < 1:
		return
	player = player[0]
	player.apply_upgrade(upgrade)

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
		"rig_change": PlayerRig.UPGRADES.WHEELS,
		"image": "image_path",
	},
	{
		"name": "Crow Bar",
		"cost": 5,
		"amount": 5,
		"description": "Increased Damage",
		"stat": "melee_damage",
		"rig_change": PlayerRig.UPGRADES.CROWBAR,
		"image": "image_path",
	},
	{
		"name": "Sign Shield",
		"cost": 5,
		"amount": 5,
		"description": "Increased Defense",
		"stat": "blocking",
		"rig_change": PlayerRig.UPGRADES.SIGNSHIELD,
		"image": "image_path",
	},
	{
		"name": "Metal Chassis",
		"cost": 5,
		"amount": 10,
		"description": "Increase Max HP",
		"stat": "maxhp",
		"rig_change": PlayerRig.UPGRADES.METALBODY,
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
