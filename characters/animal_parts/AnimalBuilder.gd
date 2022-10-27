extends Node2D

signal animal_built(genes)

var animal_parts = preload("res://characters/animal_parts/AnimalParts.tscn").instance()

export var use_random = false
export var build_on_ready = true

enum PARTS { BODY, HEAD, REAR_LEG, FRONT_LEG, TAIL, EYEBROWS }

onready var polygons: Node2D = $Polygons
onready var skeleton: Skeleton2D = $Skeleton2D
const skeleton_path = "../../Skeleton2D"
onready var anim_player: AnimationPlayer = $Skeleton2D/AnimationPlayer

const MAX_COORD = pow(2,31)-1
const MIN_COORD = -MAX_COORD
var bounding_box: Rect2

const idle_bounce_dist = 30.0
const head_rotate_dist = 3.0
const leg_rotate_dist = 15.0

# body part polygons
var body_part = null
var rear_leg_r_part = null
var rear_leg_l_part = null
var front_leg_r_part = null
var front_leg_l_part = null
var tail_part = null
var head_part = null
var eyebrows_part = null


var test_genes = {
	"body": Genes.ANIMALS.PENGUIN,
	"head": Genes.ANIMALS.HIPPO,
	"front_legs": Genes.ANIMALS.GIRAFFE,
	"rear_legs": Genes.ANIMALS.PENGUIN,
	"tail": Genes.ANIMALS.PENGUIN,
	"diet": Genes.DIETS.HERBIVORE,
	"player_response": Genes.RESPONSE.AGRESSIVE,
	"animal_response_similar": Genes.RESPONSE.CURIOUS,
	"animal_response_different": Genes.RESPONSE.FEARFUL,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if !build_on_ready:
		return
	var genes = test_genes
	if use_random:
		genes = Genes.generate_random_genes()
	build_animal(genes)

func build_random():
	var genes = Genes.generate_random_genes()
	build_animal(genes)

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		global_transform.origin = Vector2.ZERO
		for polygon in polygons.get_children():
			polygon.queue_free()
			polygons.remove_child(polygon)
		var genes = Genes.generate_random_genes()
		build_animal(genes)
	
	if Input.is_action_just_pressed("move_forward"):
		anim_player.play("walk_loop")
		
	if Input.is_action_just_pressed("move_backward"):
		anim_player.play("idle_loop")
		
	
	if Input.is_action_just_pressed("attack"):
		anim_player.play("attack")
	#print($Skeleton2D/Hip/Chest/Head.transform)
	pass

func build_animal(genes):
	#Get Body
	var body_genes = genes.get("body", null)
	if body_genes == null:
		print("Failed to make animal because no body")
		return
	body_part = get_part(PARTS.BODY, body_genes)
	if body_part == null:
		print("Failed to make animal because missing body part")
		return
	polygons.add_child(body_part)
	
	
	
	# Get mountpoints 
	var m_hip: Transform2D = body_part.get_node("Hip").global_transform
	var m_tail: Transform2D = body_part.get_node("Tail").global_transform
	var m_chest: Transform2D = body_part.get_node("Chest").global_transform
	var m_head: Transform2D = body_part.get_node("Head").global_transform
	var m_rear_leg_r: Transform2D = body_part.get_node("RearLegR").global_transform
	var m_rear_leg_l: Transform2D = body_part.get_node("RearLegL").global_transform
	var m_front_leg_r: Transform2D = body_part.get_node("FrontLegR").global_transform
	var m_front_leg_l: Transform2D = body_part.get_node("FrontLegL").global_transform
	
	#Assemble part polygons
	#Rear Legs
	var rear_legs_genes = genes.get("rear_legs", null)
	if rear_legs_genes != null:
		rear_leg_r_part = mount_part_to_body(PARTS.REAR_LEG, rear_legs_genes, m_rear_leg_r)
		rear_leg_l_part = mount_part_to_body(PARTS.REAR_LEG, rear_legs_genes, m_rear_leg_l, true)
	
	#Front Legs
	var front_legs_genes = genes.get("front_legs", null)
	if front_legs_genes != null:
		front_leg_r_part = mount_part_to_body(PARTS.FRONT_LEG, front_legs_genes, m_front_leg_r)
		front_leg_l_part = mount_part_to_body(PARTS.FRONT_LEG, front_legs_genes, m_front_leg_l, true)
	
	#Tail
	var tail_genes = genes.get("tail", null)
	if tail_genes != null:
		tail_part = mount_part_to_body(PARTS.TAIL, tail_genes, m_tail, true)
	
	#Head
	var head_genes = genes.get("head", null)
	if head_genes != null:
		head_part = mount_part_to_body(PARTS.HEAD, head_genes, m_head)
		if head_part != null:
			var m_eyebrows = head_part.get_node("Eyebrows").global_transform
			eyebrows_part = mount_part_to_body(PARTS.EYEBROWS, head_genes, m_eyebrows)
	
	
	#Build Skeleton
	attach_part_to_bone(body_part, "Hip", m_hip)
	attach_part_to_bone(tail_part, "Hip/Tail", m_tail, m_hip)
	attach_part_to_bone(rear_leg_r_part, "Hip/RearLegR", m_rear_leg_r, m_hip)
	attach_part_to_bone(rear_leg_l_part, "Hip/RearLegL", m_rear_leg_l, m_hip)
	attach_part_to_bone(null, "Hip/Chest", m_chest, m_hip)
	attach_part_to_bone(head_part, "Hip/Chest/Head", m_head, m_chest)
	attach_part_to_bone(eyebrows_part, "Hip/Chest/Head", m_head, m_chest)
	attach_part_to_bone(front_leg_r_part, "Hip/Chest/FrontLegR", m_front_leg_r, m_chest)
	attach_part_to_bone(front_leg_l_part, "Hip/Chest/FrontLegL", m_front_leg_l, m_chest)

	#Get bones
	var hip_bone = skeleton.get_node("Hip")
	var tail_bone = skeleton.get_node("Hip/Tail")
	var rear_leg_r_bone = skeleton.get_node("Hip/RearLegR")
	var rear_leg_l_bone = skeleton.get_node("Hip/RearLegL")
	var _chest_bone = skeleton.get_node("Hip/Chest")
	var head_bone = skeleton.get_node("Hip/Chest/Head")
	var front_leg_r_bone = skeleton.get_node("Hip/Chest/FrontLegR")
	var front_leg_l_bone = skeleton.get_node("Hip/Chest/FrontLegL")


	var head_rotation = rad2deg(head_bone.rest.get_rotation())
	var tail_rotation = rad2deg(tail_bone.rest.get_rotation())
	var rear_leg_r_rotation = rad2deg(rear_leg_r_bone.rest.get_rotation())
	var rear_leg_l_rotation = rad2deg(rear_leg_l_bone.rest.get_rotation())
	var front_leg_r_rotation = rad2deg(front_leg_r_bone.rest.get_rotation())
	var front_leg_l_rotation = rad2deg(front_leg_l_bone.rest.get_rotation())

	var track_index
	anim_player.clear_caches()

	var animation := Animation.new()
	animation.length = 0.001
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip:position:y")
	animation.track_insert_key(track_index, 0.0, hip_bone.rest.origin.y)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/RearLegR:position:y")
	animation.track_insert_key(track_index, 0.0, rear_leg_r_bone.rest.origin.y)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/RearLegL:position:y")
	animation.track_insert_key(track_index, 0.0, rear_leg_l_bone.rest.origin.y)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/FrontLegR:position:y")
	animation.track_insert_key(track_index, 0.0, front_leg_r_bone.rest.origin.y)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/FrontLegL:position:y")
	animation.track_insert_key(track_index, 0.0, front_leg_l_bone.rest.origin.y)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/Head:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, head_rotation)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Tail:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, tail_rotation)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/RearLegR:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, rear_leg_r_rotation)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/RearLegL:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, rear_leg_l_rotation)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/FrontLegR:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, front_leg_r_rotation)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/FrontLegL:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, front_leg_l_rotation)
	var err = anim_player.add_animation("RESET", animation)
	if err != 0:
		print("ERROR:", err)

	animation = Animation.new()
	animation.length = 2.0
	animation.loop = true
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip:position:y")
	animation.track_insert_key(track_index, 0.0, hip_bone.rest.origin.y)
	animation.track_insert_key(track_index, 1.0, hip_bone.rest.origin.y+idle_bounce_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/RearLegR:position:y")
	animation.track_insert_key(track_index, 0.0, rear_leg_r_bone.rest.origin.y)
	animation.track_insert_key(track_index, 1.0, rear_leg_r_bone.rest.origin.y-idle_bounce_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/RearLegL:position:y")
	animation.track_insert_key(track_index, 0.0, rear_leg_l_bone.rest.origin.y)
	animation.track_insert_key(track_index, 1.0, rear_leg_l_bone.rest.origin.y-idle_bounce_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/FrontLegR:position:y")
	animation.track_insert_key(track_index, 0.0, front_leg_r_bone.rest.origin.y)
	animation.track_insert_key(track_index, 1.0, front_leg_r_bone.rest.origin.y-idle_bounce_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/FrontLegL:position:y")
	animation.track_insert_key(track_index, 0.0, front_leg_l_bone.rest.origin.y)
	animation.track_insert_key(track_index, 1.0, front_leg_l_bone.rest.origin.y-idle_bounce_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/Head:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, head_rotation)
	animation.track_insert_key(track_index, 0.5, head_rotation-head_rotate_dist)
	animation.track_insert_key(track_index, 1.5, head_rotation+head_rotate_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Tail:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, tail_rotation)
	animation.track_insert_key(track_index, 0.5, tail_rotation+head_rotate_dist)
	animation.track_insert_key(track_index, 1.5, tail_rotation-head_rotate_dist)
	err = anim_player.add_animation("idle_loop", animation)
	if err != 0:
		print("ERROR:", err)
	anim_player.play("idle_loop")

	animation = Animation.new()
	animation.length = 2.0
	animation.loop = true
#	track_index = animation.add_track(Animation.TYPE_VALUE)
#	animation.track_set_path(track_index, "Hip/Chest/Head:position:y")
#	animation.track_insert_key(track_index, 0.0, head_bone.rest.origin.y)
#	animation.track_insert_key(track_index, 0.5, head_bone.rest.origin.y+idle_bounce_dist/2)
#	animation.track_insert_key(track_index, 1.0, head_bone.rest.origin.y)
#	animation.track_insert_key(track_index, 1.5, head_bone.rest.origin.y+idle_bounce_dist/2)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/Head:position:x")
	animation.track_insert_key(track_index, 0.0, head_bone.rest.origin.x)
	animation.track_insert_key(track_index, 0.5, head_bone.rest.origin.x+idle_bounce_dist/2)
	animation.track_insert_key(track_index, 1.0, head_bone.rest.origin.x)
	animation.track_insert_key(track_index, 1.5, head_bone.rest.origin.x+idle_bounce_dist/2)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/Head:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, head_rotation)
	animation.track_insert_key(track_index, 0.5, head_rotation-head_rotate_dist*2.0)
	animation.track_insert_key(track_index, 1.5, head_rotation+head_rotate_dist*2.0)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Tail:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, tail_rotation)
	animation.track_insert_key(track_index, 0.5, tail_rotation+head_rotate_dist*2.0)
	animation.track_insert_key(track_index, 1.5, tail_rotation-head_rotate_dist*2.0)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/RearLegR:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, rear_leg_r_rotation-leg_rotate_dist)
	animation.track_insert_key(track_index, 1.0, rear_leg_r_rotation+leg_rotate_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/RearLegL:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, rear_leg_l_rotation+leg_rotate_dist)
	animation.track_insert_key(track_index, 1.0, rear_leg_l_rotation-leg_rotate_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/FrontLegR:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, front_leg_r_rotation+leg_rotate_dist)
	animation.track_insert_key(track_index, 1.0, front_leg_r_rotation-leg_rotate_dist)
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Hip/Chest/FrontLegL:rotation_degrees")
	animation.track_insert_key(track_index, 0.0, front_leg_l_rotation-leg_rotate_dist)
	animation.track_insert_key(track_index, 1.0, front_leg_l_rotation+leg_rotate_dist)
	err = anim_player.add_animation("walk_loop", animation)
	if err != 0:
		print("ERROR:", err)

	#anim_player.play("walk_loop")

	animation = Animation.new()
	animation.length = 0.5
	animation.loop = false
	err = anim_player.add_animation("attack", animation)
	if err != 0:
		print("ERROR:", err)

	animation = Animation.new()
	animation.length = 2.0
	animation.loop = false
	err = anim_player.add_animation("die", animation)
	if err != 0:
		print("ERROR:", err)
	
	
	#Move to origin
	calculate_bounding_box()
	build_bounding_box_visual()
	global_transform.origin -= bounding_box.position
	
	emit_signal("animal_built", genes)


func mount_part_to_body(part, animal, mount_point, send_to_back = false):
	var part_polygon = get_part(part, animal)
	if part_polygon != null:
		#Right Leg
		polygons.add_child(part_polygon)
		if send_to_back:
			polygons.move_child(part_polygon,0)
		var mount: Transform2D = part_polygon.get_node("Mount").global_transform
		var move_dist = mount.origin - mount_point.origin
		part_polygon.global_transform.origin -= move_dist
	return part_polygon

func get_part_text(part):
	match(part):
		PARTS.BODY:
			return "Body"
		PARTS.HEAD:
			return "Head"
		PARTS.REAR_LEG:
			return "RearLeg"
		PARTS.FRONT_LEG:
			return "FrontLeg"
		PARTS.TAIL:
			return "Tail"
		PARTS.EYEBROWS:
			return "Eyebrows"
	return ""

func get_animal_text(animal):
	match(animal):
		Genes.ANIMALS.HIPPO:
			return "Hippo"
		Genes.ANIMALS.PENGUIN:
			return "Penguin"
		Genes.ANIMALS.GIRAFFE:
			return "Giraffe"
		Genes.ANIMALS.CHEETAH:
			return "Cheetah"
		Genes.ANIMALS.CROCODILE:
			return "Crocodile"
		Genes.ANIMALS.HARE:
			return "Hare"
		Genes.ANIMALS.BEAR:
			return "Bear"
		Genes.ANIMALS.TORTOISE:
			return "Tortoise"
	return ""

func get_part(part, animal):
	var lookup = get_animal_text(animal) + get_part_text(part)
	var result = animal_parts.get_node(lookup)
	if result != null:
		result = result.duplicate()
	return result
	
func minv(curvec,newvec):
	return Vector2(min(curvec.x,newvec.x),min(curvec.y,newvec.y))

func maxv(curvec,newvec):
	return Vector2(max(curvec.x,newvec.x),max(curvec.y,newvec.y))
	
func calculate_bounding_box():
	var min_vec = Vector2(MAX_COORD,MAX_COORD)
	var max_vec = Vector2(MIN_COORD,MIN_COORD)
	for polygon in polygons.get_children():
		for v in polygon.polygon:
			min_vec = minv(min_vec,v+polygon.global_transform.origin)
			max_vec = maxv(max_vec,v+polygon.global_transform.origin)
	bounding_box = Rect2(min_vec,max_vec-min_vec)
	return bounding_box

func build_bounding_box_visual():
	$BoundingBox.polygon = rect_to_polygon(bounding_box)

func rect_to_polygon(rect: Rect2):
	var result = [
		rect.position,
		Vector2(rect.position.x, rect.end.y),
		rect.end,
		Vector2(rect.end.x, rect.position.y),
	]
	return result

func attach_part_to_bone(part: Polygon2D, bone_path, rest_transform: Transform2D, parent_transform: Transform2D = Transform2D.IDENTITY):
	var bone: Bone2D = skeleton.get_node(bone_path)
	bone.transform = rest_transform.translated(-parent_transform.origin)
	bone.rest = rest_transform.translated(-parent_transform.origin)
	if part != null:
		var weights: PoolRealArray = PoolRealArray()
		weights.resize(part.polygon.size())
		weights.fill(1.0)
		part.skeleton = NodePath(skeleton_path)
		#part.add_bone(NodePath(skeleton_path + "/" + bone_path), weights)
		part.add_bone(NodePath(bone_path), weights)
	
