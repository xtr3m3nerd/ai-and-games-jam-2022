extends PanelContainer


var upgrade = {}

onready var upgrade_name = $VBoxContainer/GridContainer/Name
onready var icon = $VBoxContainer/HFlowContainer/Icon
onready var description = $VBoxContainer/HFlowContainer/VBoxContainer/Description
onready var cost = $VBoxContainer/HFlowContainer/VBoxContainer/Cost
onready var buy_button = $VBoxContainer/HFlowContainer/VBoxContainer/BuyButton

signal upgrade_purchased(upgrade)

func _ready():
	set_upgrade(upgrade)
	
func set_upgrade(_upgrade):
	upgrade = _upgrade
	if !is_inside_tree():
		return
	upgrade_name.text = upgrade.get("name", "MISSING NAME!")
	description.text = upgrade.get("description", "MISSING DESCRIPTION!")
	var cost_amount = upgrade.get("cost", 0)
	cost.text = "Cost: " + str(cost_amount)
	
	var image_path = upgrade.get("image", "")
	var directory = Directory.new()
	if directory.file_exists(image_path):
		var image = load(image_path)
		if image:
			icon.texture = image

func _on_BuyButton_pressed():
	var money = GameManager.player_data.get("money", null)
	if money == null:
		GameManager.player_data["money"] = 0
		money = 0
	var cost_amount = upgrade.get("cost", 0)
	if money < cost_amount:
		return
	GameManager.player_data["money"] -= cost_amount
	
	emit_signal("upgrade_purchased", upgrade)
	var is_persistant = upgrade.get("persistant", false)
	if !is_persistant:
		print("clear")
		queue_free()
