extends Camera

var origin: Spatial = null
var target: Spatial = null
var at_target = false

var transition_timer : Timer

var start_pos: Vector3
var start_rot: Basis

signal transition_finished

func _ready():
	origin = get_parent()
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
		global_transform.origin = lerp(target.global_transform.origin, start_pos, percent_finished)
		global_transform.basis = target.global_transform.basis.get_rotation_quat().slerp(start_rot, percent_finished)

func snap_to(_target: Spatial, transition_time = 1.0):
	if _target == target:
		return
	transition_timer.stop()
	target = _target
	at_target = false
	start_pos = global_transform.origin
	start_rot = global_transform.basis.get_rotation_quat()
	transition_timer.wait_time = transition_time
	transition_timer.start()

func finish_transition():
	transform.origin = Vector3.ZERO
	transform.basis = Basis.IDENTITY
	at_target = true
	get_parent().remove_child(self)
	target.add_child(self)
	emit_signal("transition_finished")

func return_to_origin(transition_time = 1.0):
	snap_to(origin, transition_time)
