extends Control

var upgrade_panel = preload("res://ui/UpgradePanel.tscn")

onready var upgrade_list = $Panel/UpgradeList
var player = null

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	setup_upgrades()

func setup_upgrades():
	for upgrade in GameManager.available_upgrades:
		var panel = upgrade_panel.instance()
		panel.set_upgrade(upgrade)
		panel.connect("upgrade_purchased", self, "on_purchase_upgrade")
		upgrade_list.add_child(panel)
		
	$GearsIcon/GearsAmount.text = str(GameManager.player_data["money"])

func on_purchase_upgrade(upgrade):
	print(upgrade)
	GameManager.apply_upgrade(upgrade)
	$GearsIcon/GearsAmount.text = str(GameManager.player_data["money"])
