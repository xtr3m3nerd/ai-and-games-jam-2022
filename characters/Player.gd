extends KinematicBody

var dead_screen = preload("res://ui/DeadScreen.tscn")

export var mouse_sens = 0.5

export var is_1st_person = false
export var camera_damp = 0.1
onready var camera_3rd = $Camera3rdPerson
onready var camera_1st = $Camera1stPerson

onready var character_mover = $CharacterMover
onready var health_manager = $HealthManager
onready var pickup_manager = $PickupManager 

var dead = false

func _ready():
	if is_1st_person:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	
#	pickup_manager.connect("got_pickup", health_manager, "get_pickup")
#	pickup_manager.connect("check_can_pickup", health_manager, "can_pickup")
	
	health_manager.init()
	health_manager.connect("dead", self, "kill")
#	health_manager.connect("hurt_amnt", self, "spawn_damage_numbers")
#	health_manager.connect("healed_amnt", self, "spawn_heal_numbers")
	camera_3rd.set_as_toplevel(true)
	respawn()

func respawn():
	dead = false
	character_mover.unfreeze()
	health_manager.reset()
	health_manager.init()

func _process(_delta):
	if dead: 
		return

	var move_vec = Vector3()
	if Input.is_action_pressed("move_forward"):
		move_vec += Vector3.FORWARD
	if Input.is_action_pressed("move_backward"):
		move_vec += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		move_vec += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		move_vec += Vector3.RIGHT
	character_mover.set_move_vec(move_vec)
	
	if Input.is_action_just_pressed("interact"):
		pickup_manager.grab_pickup()
	
	if Input.is_action_just_pressed("jump"):
		character_mover.jump()
	
	if global_transform.origin.y < -20:
		hurt(1000000, Vector3.ZERO)
	
func _physics_process(_delta):
	camera_3rd.global_transform.origin = lerp(camera_3rd.global_transform.origin, global_transform.origin, camera_damp)

func _input(event):
	if event is InputEventMouseMotion:
		if is_1st_person:
			rotation_degrees.y -= mouse_sens * event.relative.x
			camera_1st.rotation_degrees.x -= mouse_sens * event.relative.y
			camera_1st.rotation_degrees.x = clamp(camera_1st.rotation_degrees.x, -90, 90)
		
func hurt(damage, dir):
	print("hurt: ",damage)
	health_manager.hurt(damage, dir)
	
func heal(amount):
	health_manager.heal(amount)

func kill():
	dead = true
	character_mover.freeze()
	var dead_screen_inst = dead_screen.instance()
	get_tree().get_root().add_child(dead_screen_inst)

#func spawn_damage_numbers(damage):
#	spawn_numbers(damage, Color.red)
#
#func spawn_heal_numbers(amount):
#	spawn_numbers(amount, Color.green)
#
#func spawn_numbers(amount: int, color: Color):
#	var damage_numbers_inst = damage_numbers.instance()
#	$CanvasLayer/StatsDisplay/DamageNumberSpawn.add_child(damage_numbers_inst)
#	damage_numbers_inst.set_text(str(amount))
#	damage_numbers_inst.set_color(color)
