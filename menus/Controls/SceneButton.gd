extends Button

class_name SceneButton

enum LOAD_TYPE { NONE, SWAP, ADD }

export var scene_to_load: String
export(LOAD_TYPE) var load_type = LOAD_TYPE.NONE

func _ready():
	var err = connect("pressed", self, "_on_pressed")
	if err != 0:
		print("ERROR: ", err)

func _on_pressed():
	if scene_to_load == null:
		return
	match load_type:
		LOAD_TYPE.NONE:
			return
		LOAD_TYPE.SWAP:
			SceneManager.set_current_scene(scene_to_load)
		LOAD_TYPE.ADD:
			SceneManager.add_scene_to_current(scene_to_load)
