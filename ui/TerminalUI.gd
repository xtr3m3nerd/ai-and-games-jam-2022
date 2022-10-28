extends Control

onready var label = $VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	label.text = "All good man"


func _on_ColorRect2_gui_input(event):
	print(event)
	if event is InputEventMouseButton:
		if event.pressed:
			$HBoxContainer2/ColorRect2.color=Color.red
			
	pass # Replace with function body.


func _on_Button2_pressed():
	$HBoxContainer2/ColorRect2.color=Color.red
	pass # Replace with function body.
