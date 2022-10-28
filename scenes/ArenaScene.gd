extends Spatial

var animal_prefab = preload("res://characters/Animal.tscn")

export var lab_scene: String = "res://scenes/LabScene.tscn"
onready var player = $Player
onready var action_text = $UI/ActionText
onready var animals_parent = $Navigation/Animals

var is_at_exit = false

export var spawn_range: Vector2 = Vector2(50,50)
export var scale_range: Vector2 = Vector2(1.0,1.0)
var rng = RandomNumberGenerator.new()
export var seed_to_use = 100
export var use_full_random = true
var distance = 10000.0
var start_height = 100.0
var bodies_to_exclude = []

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.transition_music(MusicManager.MUSIC.BATTLE)
	action_text.hide()
	spawn_at_random_locations()

func spawn_at_random_locations():
	if use_full_random:
		rng.randomize()
	else:
		rng.seed = seed_to_use
	for genes in GameManager.animal_genes:
		var space_state = get_world().get_direct_space_state()
		var x = rng.randf_range(-spawn_range.x, spawn_range.x)
		var z = rng.randf_range(-spawn_range.y, spawn_range.y)
		var our_position = Vector3(x, start_height, z)
		var result = space_state.intersect_ray(our_position, our_position + Vector3.DOWN * distance,
			bodies_to_exclude, 1 + 16, true, true)
			
		if result:
			var animal = animal_prefab.instance()
			animal.genes = genes
			animals_parent.add_child(animal)
			animal.global_transform.origin = result.position
		

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if is_at_exit:
			SceneManager.set_current_scene(lab_scene)

func _on_LabEntrance_body_entered(body):
	if body == player:
		is_at_exit = true
		action_text.text = "Press 'E' to go to lab"
		action_text.show()


func _on_LabEntrance_body_exited(body):
	if body == player:
		is_at_exit = false
		action_text.hide()
