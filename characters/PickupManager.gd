extends Area

signal near_pickup
signal left_pickup
signal got_pickup
signal check_can_pickup

var cur_pickup: Pickup = null
func get_pickup():
	return cur_pickup
	
var can_pickup = false
func set_can_pickup(_can_pickup: bool):
	can_pickup = _can_pickup

func set_pickup_message(_pickup_message: String):
	if cur_pickup == null:
		return
	cur_pickup.set_text(_pickup_message)
	
func _ready():
	var err = connect("area_entered", self, "on_area_enter")
	if err:
		print("Failed connect area_entered: ", err)
	err = connect("area_exited", self, "on_area_exit")
	if err:
		print("Failed connect area_exited: ", err)
	
func on_area_enter(pickup: Pickup):
	if cur_pickup != pickup:
		if cur_pickup != null:
			cur_pickup.hide_text()
		cur_pickup = pickup
		can_pickup = false
		cur_pickup.show_text()
		emit_check_can_pickup()
	emit_signal("near_pickup", pickup)
	
func on_area_exit(pickup: Pickup):
	if cur_pickup == pickup:
		cur_pickup.hide_text()
		can_pickup = false
		cur_pickup = null
	emit_signal("left_pickup", pickup)
	
func grab_pickup():
	if cur_pickup == null:
		return
	if !can_pickup:
		return
	emit_signal("got_pickup", cur_pickup)
	cur_pickup.queue_free()
	cur_pickup = null

func emit_check_can_pickup(_dummy = null):
	emit_signal("check_can_pickup", self)

