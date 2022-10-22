extends AudioStreamPlayer3D

class_name RandomSounds

export var sounds = []

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func play_random(start_time:float = 0.0):
	if sounds.size() < 1:
		return
	var index = rng.randi_range(0, sounds.size()-1)
	stream = sounds[index]
	play(start_time)

func play_index(index, start_time:float = 0.0):
	if index >= sounds.size():
		return
	stream = sounds[index]
	play(start_time)
