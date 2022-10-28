extends ColorRect

func _ready():
	add_to_group("DRAGGABLE")

func get_drag_data(_position: Vector2):
	print("[Draggable] get_drag_data has been run")
	return self
