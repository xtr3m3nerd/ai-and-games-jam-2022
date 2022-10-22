tool
extends HBoxContainer

signal value_changed(_value)

export var label:String = "Label:" setget label_set, label_get

func label_set(_label):
	label = _label
	if is_inside_tree():
		$Label.text = label

func label_get():
	return label

export var min_value:float = 0 setget min_value_set, min_value_get

func min_value_set(_min_value):
	min_value = _min_value
	if is_inside_tree():
		$HSlider.min_value = _min_value

func min_value_get():
	return min_value

export var max_value: float = 100 setget max_value_set, max_value_get

func max_value_set(_max_value):
	max_value = _max_value
	if is_inside_tree():
		$HSlider.max_value = _max_value

func max_value_get():
	return max_value

export var value: float = 0 setget value_set, value_get

func value_set(_value):
	value = _value
	if is_inside_tree():
		$Value.text = str(_value)
	emit_signal("value_changed", _value)
	if is_inside_tree() and _value != $HSlider.value:
		$HSlider.value = _value

func value_get():
	return value

func _ready():
	$Label.text = label
	$Value.text = str(value)
	$HSlider.min_value = min_value
	$HSlider.max_value = max_value
	$HSlider.value = value
	var err = $HSlider.connect("value_changed", self, "on_value_changed")
	if err != 0:
		print("ERROR: ", err)

func on_value_changed(_value):
	if value != _value:
		value_set(_value)
