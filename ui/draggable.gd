extends ColorRect

func _ready():
	add_to_group("DRAGGABLE")

func get_drag_data(_position: Vector2):
	print("[Draggable] get_drag_data has been run")
	# Use another colorpicker as drag preview.
	var cpb = ColorRect.new()
	cpb.color = color
	cpb.rect_size = Vector2(50, 50)
	set_drag_preview(cpb)
	# Return color as drag data.
	return color


func can_drop_data(_pos, data):
	return typeof(data) == TYPE_COLOR


func drop_data(_pos, data):
	color = data
