extends KinematicBody

export var drops: Array = []

#onready var aimer = $AimAtObject
onready var character_mover = $CharacterMover
onready var animal_builder = $Graphics/AnimalVisuals/Viewport/AnimalBuilder
onready var visuals_anim_player = $Graphics/AnimalVisuals/AnimationPlayer
onready var anim_player = $Graphics/AnimalVisuals/Viewport/AnimalBuilder.anim_player
onready var health_manager = $HealthManager
onready var graphics = $Graphics
#onready var skeleton = $Graphics/Armature/Skeleton
onready var collision_shape = $CollisionShape
var nav : Navigation

enum STATES {IDLE, CHASE, ATTACK, DEAD}
var cur_state = STATES.IDLE

var player = null
var path = []

export var sight_angle = 45.0
export var turn_speed = 360.0
export var sight_range = 50.0
export var search_time = 1.0
var search_timer : Timer

export var attack_angle = 5.0
export var attack_range = 2.0
export var attack_rate = 1.0
export var attack_anim_speed_mod = 1
export var can_turn_while_attacking = false
var attack_timer : Timer
var can_attack = true
export var aggro_on_sight = true
var aggroed = false

var genes = null

#var aimer_ranged
#export var seperate_ranged_attack = false
#export var ranged_attack_range = 100
#export var ranged_attack_frequency = 8
#var ranged_attack_timer : Timer


signal attack
signal engaged

	
func _ready():
	if genes == null:
		animal_builder.build_random()
	else:
		animal_builder.build_animal(genes)
	if get_parent().get_class() == "Navigation":
		nav = get_parent()
	else:
		nav = get_parent().get_parent()
	search_timer = Timer.new()
	search_timer.wait_time = search_time
	var err = search_timer.connect("timeout", self, "set_state_idle")
	if err:
		print("Failed connect search_timer: ", err)
	search_timer.one_shot = true
	add_child(search_timer)
	
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	err = attack_timer.connect("timeout", self, "finish_attack")
	if err:
		print("Failed connect attack_timer: ", err)
	attack_timer.one_shot = true
	add_child(attack_timer)
	
#	ranged_attack_timer = Timer.new()
#	ranged_attack_timer.wait_time = ranged_attack_frequency
#	err = ranged_attack_timer.connect("timeout", self, "ranged_attack")
#	if err:
#		print("Failed connect attack_timer: ", err)
#	ranged_attack_timer.one_shot = false
#	add_child(ranged_attack_timer)
	
	player = get_tree().get_nodes_in_group("player")[0]
#	var bone_attachments = skeleton.get_children()
#	for bone_attachment in bone_attachments:
#		for child in bone_attachment.get_children():
#			if child is HitBox:
#				child.connect("hurt", self, "hurt")
	health_manager.connect("dead", self, "set_state_dead")
	health_manager.connect("gibbed", graphics, "hide")
	health_manager.connect("gibbed", self, "disable_hitboxes")
	character_mover.init(self)
	
#	for attack in aimer.get_children():
#		if attack.has_method("set_bodies_to_exclude"):
#			attack.set_bodies_to_exclude([self])
#	if seperate_ranged_attack:
#		aimer_ranged = $AimAtObjectRanged
#	if seperate_ranged_attack and aimer_ranged:
#		for attack in aimer_ranged.get_children():
#			if attack.has_method("set_bodies_to_exclude"):
#				attack.set_bodies_to_exclude([self])
	set_state_idle()

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)

func set_state_idle():
	if cur_state == STATES.DEAD:
		return
#	ranged_attack_timer.stop()
	character_mover.set_move_vec(Vector3.ZERO)
	cur_state = STATES.IDLE
	anim_player.play("idle_loop")
	
func set_state_chase():
	if cur_state == STATES.DEAD:
		return
	aggroed = true
#	if seperate_ranged_attack and ranged_attack_timer.is_stopped():
#		ranged_attack_timer.start()
	if cur_state == STATES.IDLE:
		emit_signal("engaged", self)
	cur_state = STATES.CHASE
	anim_player.play("walk_loop", 0.2)
	
func set_state_attack():
	if cur_state == STATES.DEAD:
		return
	aggroed = true
#	if seperate_ranged_attack and ranged_attack_timer.is_stopped():
#		ranged_attack_timer.start()
	if cur_state == STATES.IDLE:
		emit_signal("engaged", self)
	cur_state = STATES.ATTACK
	
func set_state_dead():
	aggroed = false
#	ranged_attack_timer.stop()
	cur_state = STATES.DEAD
	anim_player.play("die", 0.2)
	search_timer.stop()
	character_mover.freeze()
	collision_shape.disabled = true
	perform_drops()
	visuals_anim_player.play("dead")

func process_state_idle(_delta):
	if can_see_player() and (aggro_on_sight or aggroed):
		set_state_chase()

func process_state_chase(delta):
	if within_dis_of_player(attack_range) and can_see_player():
		set_state_attack()
		return
	if !has_los_player(): 
		if search_timer.is_stopped():
			search_timer.start()
	elif !search_timer.is_stopped():
		search_timer.stop()
	var player_pos = player.global_transform.origin
	var our_pos = global_transform.origin
	path = nav.get_simple_path(our_pos, player_pos)
	var goal_pos = player_pos
	if path.size() > 1:
		goal_pos = path[1]
	var dir = goal_pos - our_pos
	dir.y = 0
	character_mover.set_move_vec(dir)
	
	face_dir(dir, delta)

func process_state_attack(delta):
	character_mover.set_move_vec(Vector3.ZERO)
	
	if can_attack:
		if !within_dis_of_player(attack_range) or !can_see_player():
			set_state_chase()
		elif !player_within_angle(attack_angle):
			face_dir(global_transform.origin.direction_to(player.global_transform.origin), delta)
		else:
			start_attack()
	else:
		if can_turn_while_attacking and !player_within_angle(attack_angle):
			face_dir(global_transform.origin.direction_to(player.global_transform.origin), delta)

func process_state_dead(_delta):
	pass

func hurt(damage: int, dir: Vector3):
	if cur_state == STATES.IDLE:
		set_state_chase()
	health_manager.hurt(damage, dir)
	if cur_state != STATES.DEAD:
		print("play hurt")
		visuals_anim_player.play("hurt")

func disable_hitboxes():
	pass
#	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
#	for bone_attachment in bone_attachments:
#		for child in bone_attachment.get_children():
#			if child is HitBox:
#				for hitbox_collision_shape in child.get_children():
#					if hitbox_collision_shape is CollisionShape:
#						hitbox_collision_shape.disabled = true

func start_attack():
	can_attack = false
	anim_player.play("attack", -1, attack_anim_speed_mod)
	attack_timer.start()
#	aimer.aim_at_pos(player.global_transform.origin + Vector3.UP)

func emit_attack_signal():
	emit_signal("attack")

func finish_attack():
	can_attack = true
	

func check_interupt_attack():
	if cur_state == STATES.DEAD:
		return
	if !within_dis_of_player(attack_range) or !can_see_player():
		can_attack = true
		set_state_chase()

func can_see_player():
	return player_within_angle(sight_angle) and has_los_player()
	
func player_within_angle(angle: float):
	var dir_to_player = global_transform.origin.direction_to(player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(dir_to_player)) < angle

func has_los_player():
	var our_pos = global_transform.origin + Vector3.UP
	var player_pos = player.global_transform.origin + Vector3.UP
	
	if our_pos.distance_to(player_pos) > sight_range:
		return false
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_pos, [], 1)
	if result:
		return false
	return true

func alert(check_los=true):
	if cur_state != STATES.IDLE:
		return
	if check_los and !has_los_player():
		return
	set_state_chase()

func face_dir(dir: Vector3, delta):
	var angle_diff = global_transform.basis.z.angle_to(dir)
	var turn_right = sign(global_transform.basis.x.dot(dir))
	if abs(angle_diff) < deg2rad(turn_speed) * delta:
		rotation.y = atan2(dir.x, dir.z)
	else:
		rotation.y += deg2rad(turn_speed) * delta * turn_right

func within_dis_of_player(dis: float):
	return global_transform.origin.distance_to(player.global_transform.origin) < dis

func reset():
	reset_aggro()
	health_manager.reset()
	health_manager.init()

func reset_aggro():
	aggroed = false
	set_state_idle()
	
func perform_drops():
	for drop in drops:
		var drop_inst = drop.instance()
		get_tree().get_root().add_child(drop_inst)
		drop_inst.global_transform.origin = global_transform.origin + Vector3.UP/2


func ranged_attack():
	pass
#	if !seperate_ranged_attack or !aimer_ranged:
#		return
#	if !within_dis_of_player(ranged_attack_range):
#		return
#	aimer_ranged.aim_at_pos(player.global_transform.origin + Vector3.UP)
#	for attack in aimer_ranged.get_children():
#		if attack.has_method("fire"):
#			attack.fire()
	
