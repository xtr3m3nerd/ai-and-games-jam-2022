extends ColorRect


func _ready():
	pass # Replace with function body.


func can_drop_data(_position: Vector2, data) -> bool:
	var can_drop: bool = data is Node and data.is_in_group("DRAGGABLE")
	print("[TargetContainer] can_drop_data has run, returning %s" % can_drop)
	return can_drop

func drop_data(_position: Vector2, _data) -> void:
	print("[TargetContainer] drop_data has run")
