extends Control

var last_focus = null

func _ready():
	last_focus = get_focus_owner()
	$VBoxContainer/BackButton.grab_focus()

func _on_back_button_pressed():
	UiSoundManager.play_button()
	if last_focus != null:
		last_focus.grab_focus()
	get_parent().remove_child(self)
