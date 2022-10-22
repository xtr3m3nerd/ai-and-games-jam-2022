extends Node

var current_scene

func _ready():
	current_scene = get_tree().current_scene

func load_scene(scene_path: String):
	print("Loading Scene: ", scene_path)
	var scene = load(scene_path)
	if !scene:
		print("Failed to load scene: ", scene_path)
		return null
	return scene.instance()

func set_current_scene(scene_path: String):
	var err = get_tree().change_scene(scene_path)
	if err != 0:
		print("ERROR: ", err)
	current_scene = get_tree().current_scene
#	var scene = load_scene(scene_path)
#	if !scene:
#		print("Scene not instanced: ", scene_path)
#		return
#	get_tree().current_scene.add_child(scene)
#	current_scene.get_parent().remove_child(current_scene)
#	current_scene = scene

func add_scene_to_current(scene_path: String):
	var scene = load_scene(scene_path)
	if !scene:
		print("Scene not instanced: ", scene_path)
		return
	get_tree().current_scene.add_child(scene)
