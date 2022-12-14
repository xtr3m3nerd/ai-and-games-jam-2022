extends Spatial

onready var animal_builder = $Viewport/AnimalBuilder
onready var anim_player = $Viewport/AnimalBuilder/Skeleton2D/AnimationPlayer
onready var quad = $ViewportQuad
onready var viewport = $Viewport
const width_buffer = 500.0

func _ready():
	var err = animal_builder.connect("animal_built", self, "on_animal_built")
	if err != 0:
		print("ERROR:", err)
	setup_viewport()
	

func setup_viewport():
	# Clear the viewport.
	#viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

	# Let two frames pass to make sure the vieport is captured.
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Retrieve the texture and set it to the viewport quad.
	quad.material_override.albedo_texture = viewport.get_texture()
 
func on_animal_built(_genes):
	var size = animal_builder.bounding_box.size
	animal_builder.global_transform.origin.x += width_buffer/2.0
	size.x += width_buffer
	viewport.size = size
	quad.mesh.size = size / 500
	quad.transform.origin.y = quad.mesh.size.y / 2.0
	print("viewport: ", viewport.size)
	print("quad: ", quad.mesh.size)
