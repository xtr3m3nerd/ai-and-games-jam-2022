extends Spatial

#var damage_numbers = preload("res://effects/DamageNumbers.tscn")
#var blood_spray = preload("res://effects/BloodSpray.tscn")
#var gibs = preload("res://effects/assets/Gibs.tscn")

signal dead
signal hurt
signal hurt_amnt
signal healed
signal healed_amnt
signal health_changed
signal gibbed

export var max_health = 100
var cur_health = 1

export var gib_at = -10
export var num_of_gibs = 4
var gibbed = false
export var damage_after_death = false
var dead = false
export var block_amount = 0
export var show_damage_numbers = true
export var show_blood_spray = true

func _ready():
	init()
	
func init():
	cur_health = max_health
	emit_signal("health_changed", cur_health)

func reset():
	gibbed = false
	dead = false
	
func hurt(damage: int, dir: Vector3, _damage_type="normal"):
	print(get_parent().name, " received ", damage, " with ", block_amount , " blocked")
	var damage_amnt = max(damage-block_amount,0)
	spawn_blood(dir)
	if show_damage_numbers:
		spawn_damage_numbers(damage_amnt)
	if cur_health <= 0 and !damage_after_death:
		return
	cur_health -= damage_amnt
	if !gibbed and cur_health <= gib_at:
		spawn_gibs()
		gibbed = true
		emit_signal("gibbed")
	if !dead and cur_health <= 0:
		dead = true
		emit_signal("dead")
	elif !dead:
		emit_signal("hurt")
		emit_signal("hurt_amnt", damage_amnt)
	emit_signal("health_changed", cur_health)
	
func heal(amount: int):
	if cur_health <= 0:
		return
	cur_health += amount
	if cur_health > max_health:
		cur_health = max_health
	emit_signal("healed")
	emit_signal("healed_amnt", amount)
	emit_signal("health_changed", cur_health)
	
func spawn_blood(_dir):
	pass
#	if !show_blood_spray:
#		return
#	var blood_spray_inst = blood_spray.instance()
#	get_tree().get_root().add_child(blood_spray_inst)
#	blood_spray_inst.global_transform.origin = global_transform.origin
#
#	if dir.angle_to(Vector3.UP) < 0.00005:
#		return
#	if dir.angle_to(Vector3.DOWN) < 0.00005:
#		blood_spray_inst.rotate(Vector3.RIGHT, PI)
#		return
#
#	var y = dir
#	var x = y.cross(Vector3.UP)
#	var z = x.cross(y)
#
#	blood_spray_inst.global_transform.basis = Basis(x,y,z)

func spawn_gibs():
	pass
#	var gibs_inst = gibs.instance()
#	get_tree().get_root().add_child(gibs_inst)
#	gibs_inst.global_transform.origin = global_transform.origin
#	gibs_inst.num_of_gibs = num_of_gibs
#	gibs_inst.init()

#func get_pickup(pickup: Pickup, _is_upgrade):
#	match pickup.pickup_type:
#		Pickup.PICKUP_TYPE.HELL_FRUIT:
#			heal(pickup.amount)
#		Pickup.PICKUP_TYPE.GIB:
#			heal(pickup.amount)

#func can_pickup(pickup_manager):
#	var pickup = pickup_manager.get_pickup()
#	if pickup == null:
#		return
#	var result = false
#	var is_food = false
#	match pickup.pickup_type:
#		Pickup.PICKUP_TYPE.HELL_FRUIT:
#			result = cur_health < max_health
#			is_food = true
#		Pickup.PICKUP_TYPE.GIB:
#			result = cur_health < max_health
#			is_food = true
#
#	if is_food:
#		if result:
#			pickup_manager.set_pickup_message("Press 'E' to eat")
#		else:
#			pickup_manager.set_pickup_message("Already full Health")
#
#	if result: 
#		pickup_manager.set_can_pickup(true)

func set_block_amount(amnt):
	block_amount = amnt

func spawn_damage_numbers(_damage):
	pass
#	var damage_numbers_inst = damage_numbers.instance()
#	get_tree().get_root().add_child(damage_numbers_inst)
#	damage_numbers_inst.global_transform.origin = global_transform.origin
#	damage_numbers_inst.set_text(str(damage))
#	damage_numbers_inst.set_color(Color.red)
