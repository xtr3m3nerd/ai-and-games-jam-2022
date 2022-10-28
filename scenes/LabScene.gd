extends Spatial

enum STATE { FREE_ROAM, USING_COMPUTER, PERFORMING_UPGRADES }
var cur_state = STATE.FREE_ROAM

var spatial_mover = preload("res://scripts/spatial_mover.tscn")

export var arena_scene: String = "res://scenes/ArenaScene.tscn"
onready var player = $Player

onready var freeroam_ui = $CanvasLayer/UI/FreeRoam
onready var freeroam_action_text = $CanvasLayer/UI/FreeRoam/ActionText
onready var computer_ui = $CanvasLayer/UI/Computer
onready var upgrades_ui = $CanvasLayer/UI/Upgrades

onready var computer_camera_pos = $Environment/ComputerCameraPos
onready var upgrade_camera_pos = $Environment/UpgradeCameraPos
onready var upgrade_stand_pos = $Environment/UpgradeStandPos


var is_at_exit = false
var is_at_computer = false
var is_at_upgrades = false

var camera = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.first_spawn:
		GameManager.first_spawn = false
	else: 
		player.global_transform.origin = $DoorSpawn.global_transform.origin
	camera = get_tree().get_nodes_in_group("snap_to_camera")[0]
	if camera == null:
		print("ERROR: Could not find snap_to_camera")
	var err = camera.connect("transition_finished", self, "camera_in_position")
	if err != 0:
		print("ERROR connecting signal", err)
	MusicManager.transition_music(MusicManager.MUSIC.LAB)
	freeroam_ui.show()
	freeroam_action_text.hide()
	computer_ui.hide()
	upgrades_ui.hide()
	

func _process(_delta):
	match(cur_state):
		STATE.FREE_ROAM:
			if Input.is_action_just_pressed("interact"):
				if is_at_exit:
					SceneManager.set_current_scene(arena_scene)
				if is_at_computer:
					change_state(STATE.USING_COMPUTER)
				if is_at_upgrades:
					change_state(STATE.PERFORMING_UPGRADES)
		STATE.USING_COMPUTER:
			if Input.is_action_just_pressed("cancel"):
				change_state(STATE.FREE_ROAM)
		STATE.PERFORMING_UPGRADES:
			if Input.is_action_just_pressed("cancel"):
				change_state(STATE.FREE_ROAM)

func change_state(new_state):
	# Close out previous states
	match(cur_state):
		STATE.FREE_ROAM:
			freeroam_ui.hide()
		STATE.USING_COMPUTER:
			computer_ui.hide()
			leave_computer()
		STATE.PERFORMING_UPGRADES:
			upgrades_ui.hide()
			leave_upgrades()
			
	match(new_state):
		STATE.FREE_ROAM:
			pass
		STATE.USING_COMPUTER:
			access_computer()
		STATE.PERFORMING_UPGRADES:
			access_upgrades()
	
	cur_state = new_state

func camera_in_position():
	match(cur_state):
		STATE.FREE_ROAM:
			freeroam_ui.show()
		STATE.USING_COMPUTER:
			computer_ui.show()
		STATE.PERFORMING_UPGRADES:
			upgrades_ui.show()

func access_computer():
	print("Accessed Computer")
	camera.snap_to(computer_camera_pos)

func leave_computer():
	print("Leaving Computer")
	camera.return_to_origin()

func access_upgrades():
	print("Accessed Upgrades")
	camera.snap_to(upgrade_camera_pos)
	player.freeze()
	var mover = spatial_mover.instance()
	player.add_child(mover)
	mover.snap_to(upgrade_stand_pos)

func leave_upgrades():
	print("Leaving Upgrades")
	camera.return_to_origin()
	player.unfreeze()


func _on_ExitArea_body_entered(body):
	if body == player:
		is_at_exit = true
		freeroam_action_text.text = "Press 'E' to go to arena"
		freeroam_action_text.show()


func _on_ExitArea_body_exited(body):
	if body == player:
		is_at_exit = false
		freeroam_action_text.hide()


func _on_ComputerArea_body_entered(body):
	if body == player:
		is_at_computer = true
		freeroam_action_text.text = "Press 'E' to use computer"
		freeroam_action_text.show()


func _on_ComputerArea_body_exited(body):
	if body == player:
		is_at_computer = false
		freeroam_action_text.hide()


func _on_UpgradeArea_body_entered(body):
	if body == player:
		is_at_upgrades = true
		freeroam_action_text.text = "Press 'E' to manage upgrades"
		freeroam_action_text.show()


func _on_UpgradeArea_body_exited(body):
	if body == player:
		is_at_upgrades = false
		freeroam_action_text.hide()


func _on_ExitArea_mouse_entered():
	freeroam_action_text.text = "Mouse in area"
	freeroam_action_text.show()
