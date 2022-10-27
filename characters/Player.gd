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

enum STATE { IDLE, WALKING, ATTACKING, BLOCKING, DEAD }
var cur_state = STATE.IDLE
var performing_action = false
onready var anim_player: AnimationPlayer = $Graphics/PlayerVisuals/Viewport/PlayerRig/AnimationPlayer
onready var player_rig = $Graphics/PlayerVisuals/Viewport/PlayerRig

func _ready():
	for upgrade in GameManager.player_data["applied_upgrades"]:
		apply_upgrade(upgrade)
	if is_1st_person:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	
	var err = anim_player.connect("animation_finished", self, "on_animation_finished")
	if err != 0:
		print("ERROR: unable to connect to animation_finished: ", err)
	
#	pickup_manager.connect("got_pickup", health_manager, "get_pickup")
#	pickup_manager.connect("check_can_pickup", health_manager, "can_pickup")
	
	health_manager.init()
	health_manager.connect("dead", self, "kill")
#	health_manager.connect("hurt_amnt", self, "spawn_damage_numbers")
#	health_manager.connect("healed_amnt", self, "spawn_heal_numbers")
	camera_3rd.set_as_toplevel(true)
	respawn()

func respawn():
	performing_action = false
	change_state(STATE.IDLE)
	character_mover.unfreeze()
	health_manager.reset()
	health_manager.init()

func _process(_delta):
	if cur_state == STATE.DEAD:
		return

	var move_vec = Vector3.ZERO
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
	
	if Input.is_action_just_pressed("attack"):
		change_state(STATE.ATTACKING)
		
	if Input.is_action_just_pressed("block"):
		change_state(STATE.BLOCKING)
	
	if global_transform.origin.y < -20:
		hurt(1000000, Vector3.ZERO)
	
	if !performing_action:
		if move_vec == Vector3.ZERO and cur_state != STATE.IDLE:
			change_state(STATE.IDLE)
		elif move_vec != Vector3.ZERO and cur_state != STATE.WALKING:
			change_state(STATE.WALKING)
	
	var mouse_pos = get_viewport().get_mouse_position()
	var camera: Camera = get_viewport().get_camera()
	var screen_space = camera.unproject_position(global_transform.origin)
	player_rig.flip(mouse_pos.x > screen_space.x)
	
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
	change_state(STATE.DEAD)
	character_mover.freeze()
	var dead_screen_inst = dead_screen.instance()
	get_tree().get_root().add_child(dead_screen_inst)

func freeze():
	character_mover.freeze()

func unfreeze():
	character_mover.unfreeze()

func change_state(new_state):
	# Close out previous states
	match(cur_state):
		STATE.IDLE:
			pass
		STATE.WALKING:
			pass
		STATE.ATTACKING:
			pass
		STATE.BLOCKING:
			pass
		STATE.DEAD:
			pass
			
	match(new_state):
		STATE.IDLE:
			anim_player.play("idle_loop")
		STATE.WALKING:
			anim_player.play("walk_loop")
		STATE.ATTACKING:
			performing_action = true
			anim_player.play("attack")
			#TODO - Add logic for attacking
		STATE.BLOCKING:
			performing_action = true
			anim_player.play("block")
			#TODO - Add logic for blocking
		STATE.DEAD:
			performing_action = true
			anim_player.play("die")
	
	cur_state = new_state

func on_animation_finished(_anim_name):
	match(cur_state):
		STATE.IDLE:
			pass
		STATE.WALKING:
			pass
		STATE.ATTACKING:
			performing_action = false
		STATE.BLOCKING:
			performing_action = false
		STATE.DEAD:
			pass

func apply_upgrade(upgrade):
	player_rig.upgrade_rig(upgrade.get("rig_change"))
	
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
