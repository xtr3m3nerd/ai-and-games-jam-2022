extends Control


func _ready():
	pass # Replace with function body.

func _process(_delta):
	if Input.is_action_just_pressed("respawn"):
		var level = get_tree().get_nodes_in_group("level")
		if level != null and level.size() > 0:
			level[0].respawn()
		else:
			var err = get_tree().reload_current_scene()
			if err:
				print("Failed to reload scene: ", err)
		queue_free()
