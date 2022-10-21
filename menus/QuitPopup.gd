extends Control

var last_focus = null

func _ready():
	last_focus = get_focus_owner()
	$PanelContainer/Buttons/HBoxContainer/YesButton.grab_focus()

func _process(_delta):
	if Input.is_action_just_pressed("exit") and OS.get_name() != "Web":
		get_tree().quit()

func _on_yes_button_pressed():
	UiSoundManager.play_button()
	get_tree().quit()

func _on_no_button_pressed():
	UiSoundManager.play_button()
	if last_focus != null:
		last_focus.grab_focus()
	GameManager.is_quiting = false
	get_parent().remove_child(self)
