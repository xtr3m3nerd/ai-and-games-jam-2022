extends Area

export var bodies_to_exclude = []
export var damage = 1

func set_damage(_damage: int):
	damage = _damage
	
func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func fire():
	if !is_visible_in_tree():
		return
	for body in get_overlapping_bodies():
		if body.has_method("hurt") and !body in bodies_to_exclude:
			body.hurt(damage, global_transform.origin.direction_to(body.global_transform.origin))
