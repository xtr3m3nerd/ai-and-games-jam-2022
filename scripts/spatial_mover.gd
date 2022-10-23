extends Spatial

var parent: Spatial = null
var target: Spatial = null
var at_target = false

var transition_timer : Timer

var start_pos: Vector3
var start_rot: Basis

signal transition_finished

func _ready():
	parent = get_parent()
	transition_timer = Timer.new()
	var err = transition_timer.connect("timeout", self, "finish_transition")
	if err:
		print("Failed connect transition_timer: ", err)
	transition_timer.one_shot = true
	add_child(transition_timer)

func _process(_delta):
	if at_target:
		return
	
	if !transition_timer.is_stopped():
		var percent_finished = transition_timer.time_left / transition_timer.wait_time
		parent.global_transform.origin = lerp(target.global_transform.origin, start_pos, percent_finished)
		parent.global_transform.basis = target.global_transform.basis.get_rotation_quat().slerp(start_rot, percent_finished)

func snap_to(_target: Spatial, transition_time = 1.0):
	if _target == target:
		return
	transition_timer.stop()
	target = _target
	at_target = false
	start_pos = parent.global_transform.origin
	start_rot = parent.global_transform.basis.get_rotation_quat()
	transition_timer.wait_time = transition_time
	transition_timer.start()

func finish_transition():
	parent.global_transform.origin = target.global_transform.origin
	parent.global_transform.basis = target.global_transform.basis
	at_target = true
	parent.remove_child(self)
	emit_signal("transition_finished")
	queue_free()

