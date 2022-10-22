extends Area

class_name Pickup

signal destroyed

enum PICKUP_TYPE { NONE }

export(PICKUP_TYPE) var pickup_type
export var amount = 1

func _ready():
	set_item_state(pickup_type)
	$PickupText.hide()

func disable_all_items():
	pass

func set_item_state(type):
	disable_all_items()
	pickup_type = type
	match(type):
		PICKUP_TYPE.NONE:
			pass

func show_text():
	$PickupText.show()

func hide_text():
	$PickupText.hide()

func set_text(text: String):
	$PickupText.text = text

func _exit_tree():
	emit_signal("destroyed")
