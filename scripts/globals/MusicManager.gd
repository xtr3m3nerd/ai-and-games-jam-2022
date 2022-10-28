extends Node

onready var track1: AudioStreamPlayer = $Track1
onready var track2: AudioStreamPlayer = $Track2

# TODO - replace this with the starting music
var menu_music = load("res://assets/sounds/music/hippotato_game_menu_final.wav")
var story_music = load("res://assets/sounds/music/hippotato_game_intro_final.wav")
var lab_music = load("res://assets/sounds/music/hippotato_game_menu_final.wav")
var battle_music = load("res://assets/sounds/music/hippotato_game_battle_theme_final.wav")

enum MUSIC { MENU, STORY, LAB, BATTLE }

func get_song_from_enum(music):
	match(music):
		MUSIC.MENU:
			return menu_music
		MUSIC.STORY:
			return story_music
		MUSIC.LAB:
			return lab_music
		MUSIC.BATTLE:
			return battle_music
	print("Error finding song: ", music)
	return null

var fade_timer: Timer

var cur_music = MUSIC.MENU
var cur_track = null
var pre_track = null

var min_volume = -20.0
var max_volume = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	fade_timer = Timer.new()
	fade_timer.one_shot = true
	var err = fade_timer.connect("timeout", self, "finish_fade")
	if err:
		print("Failed connect fade_timer: ", err)
	add_child(fade_timer)
	cur_track = track1
	pre_track = track2

func play_music(music):
	var song = get_song_from_enum(music)
	if song == null:
		return
	cur_track = track1
	pre_track = track2
	cur_track.stop()
	pre_track.stop()
	fade_timer.stop()
	cur_track.stream = song
	cur_track.play()

func transition_music(music, transition_time: float = 1.0):
	if cur_music == music:
		return
	
	var song = get_song_from_enum(music)
	if song == null:
		return
	
	fade_timer.wait_time = transition_time
	var temp_track = pre_track
	pre_track = cur_track
	cur_track = temp_track
	cur_track.stream = song
	cur_track.play()
	fade_timer.start()

func _process(_delta):
	if fade_timer.is_stopped():
		return
	var percent = fade_timer.time_left / fade_timer.wait_time
	if pre_track:
		pre_track.volume_db = lerp(min_volume, max_volume, percent)
		
	if cur_track:
		cur_track.volume_db = lerp(min_volume, max_volume, 1.0-percent)

func finish_fade():
	if pre_track:
		pre_track.stop()
	if cur_track:
		cur_track.volume_db = max_volume
