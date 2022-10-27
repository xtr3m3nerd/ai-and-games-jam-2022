extends PanelContainer


var upgrade = {}

onready var upgrade_name = $VBoxContainer/GridContainer/Name
onready var icon = $VBoxContainer/HFlowContainer/Icon
onready var description = $VBoxContainer/HFlowContainer/VBoxContainer/Description
onready var cost = $VBoxContainer/HFlowContainer/VBoxContainer/Cost
onready var buy_button: Button = $VBoxContainer/HFlowContainer/VBoxContainer/BuyButton

var cost_amount = 0

signal upgrade_purchased(upgrade)

func _ready():
	var err = GameManager.connect("player_updated", self, "on_player_updated")
	if err != 0:
		print("ERROR: ", err)
	set_upgrade(upgrade)
	
func set_upgrade(_upgrade):
	upgrade = _upgrade
	if !is_inside_tree():
		return
	upgrade_name.text = upgrade.get("name", "MISSING NAME!")
	description.text = upgrade.get("description", "MISSING DESCRIPTION!")
	cost_amount = upgrade.get("cost", 0)
	cost.text = "Cost: " + str(cost_amount)
	
	var image_path = upgrade.get("image", "")
	var directory = Directory.new()
	if directory.file_exists(image_path):
		var image = load(image_path)
		if image:
			icon.texture = image

func _on_BuyButton_pressed():
	if !can_afford():
		return
	var money = GameManager.player_data["money"]
	GameManager.modify_player_data("money", money - cost_amount)
	
	emit_signal("upgrade_purchased", upgrade)
	var is_persistant = upgrade.get("persistant", false)
	if !is_persistant:
		print("clear")
		queue_free()

func can_afford():
	var money = GameManager.player_data.get("money")
	return money >= cost_amount

func change_buy_button_state(disabled: bool):
	buy_button.disabled = disabled

func on_player_updated(_player_data):
	change_buy_button_state(!can_afford())
