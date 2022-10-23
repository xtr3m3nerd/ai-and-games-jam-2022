extends Spatial

onready var camera_pos = $InnerGimbal/CameraPos
export var rotation_speed = PI/2
export var max_zoom = 1.0
export var min_zoom = 0.25
export var zoom = 0.75
export var zoom_speed = 0.05

export var mouse_control = true
export var invert_x = false
export var invert_y = false
export var mouse_sensitivity = 0.005
export var lower_y_limit = -1.4
export var upper_y_limit = 1.4
var y_clamp = 30


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !mouse_control:
		get_input_keyboard(delta)
	$InnerGimbal.rotation.x = clamp($InnerGimbal.rotation.x, lower_y_limit, upper_y_limit)
	scale = lerp(scale, Vector3.ONE * zoom, zoom_speed)

func _unhandled_input(event):
	if mouse_control and event is InputEventMouseMotion:
		if event.relative.x != 0:
			var dir = 1 if invert_x else -1
			rotate_object_local(Vector3.UP, dir * event.relative.x * mouse_sensitivity)
		if event.relative.y != 0:
			var dir = 1 if invert_y else -1
			var y_relative = clamp(event.relative.y, -y_clamp, y_clamp)
			$InnerGimbal.rotate_object_local(Vector3.RIGHT, dir * y_relative * mouse_sensitivity)
	if event.is_action_pressed("cam_zoom_in"):
		zoom -= zoom_speed
	if event.is_action_pressed("cam_zoom_out"):
		zoom += zoom_speed
	zoom = clamp(zoom, min_zoom, max_zoom)

func get_input_keyboard(delta):
	# Rotate outer gimbal around y axis
	var y_rotation = 0
	if Input.is_action_pressed("cam_right"):
		y_rotation += 1
	if Input.is_action_pressed("cam_left"):
		y_rotation -= 1
	rotate_object_local(Vector3.UP, y_rotation * rotation_speed * delta)
	
	# Rotate inner gimbal around x axis
	var x_rotation = 0
	if Input.is_action_pressed("cam_up"):
		x_rotation -= 1
	if Input.is_action_pressed("cam_down"):
		x_rotation += 1
	$InnerGimbal.rotate_object_local(Vector3.RIGHT, x_rotation * rotation_speed * delta)

func grab_camera():
	var camera = get_tree().get_nodes_in_group("snap_to_camera")[0]
	if camera != null:
		camera.snap_to(camera_pos)
