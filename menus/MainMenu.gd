extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Buttons/StartButton.grab_focus()
	if OS.get_name() == "Web":
		$Buttons/QuitButton.hide()
	MusicManager.play_music(MusicManager.MUSIC.MENU)


func _on_quit_button_pressed():
	GameManager.quit_game()


func _on_button_pressed():
	UiSoundManager.play_button()
