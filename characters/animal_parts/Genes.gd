extends Node

class_name Genes

enum ANIMALS { HIPPO, PENGUIN, GIRAFFE, CHEETAH } #, CROCODILE, HARE, BEAR, TORTOISE}
enum DIETS { HERBIVORE, OMNIVORE, CARNIVORE }
enum RESPONSE { AGRESSIVE, FEARFUL, CURIOUS, NONE }
enum RESPONSE_RANGE { ALL, SIMILAR, DIFFERENT }

var genes = {
	"body": ANIMALS.HIPPO,
	"head": ANIMALS.HIPPO,
	"front_legs": ANIMALS.HIPPO,
	"rear_legs": ANIMALS.HIPPO,
	"tail": ANIMALS.HIPPO,
	"diet": DIETS.HERBIVORE,
	"player_response": RESPONSE.AGRESSIVE,
	"animal_response_similar": RESPONSE.CURIOUS,
	"animal_response_different": RESPONSE.FEARFUL,
}

static func breed_genes(parentA, parentB, _seed = null):
	var rng = get_rng(_seed)
	var combined_genes = parentA.merge(parentB)
	var result = {}
	for key in combined_genes.keys():
		var value = null
		if rng.randi() % 2 == 0:
			value = parentA.get(key)
		else:
			value = parentB.get(key)
		
		if value != null:
			result[key] = value
	return result

static func compare_genes(A, B):
	var combined_genes = A.merge(B)
	var total = combined_genes.keys().size()
	var count = 0
	for key in combined_genes.keys():
		if A.get(key) == B.get(key):
			count += 1
	return count/total

static func generate_random_genes(_seed = null):
	var rng = get_rng(_seed)
	var result = {
		"body": rng.randi() % ANIMALS.size(),
		"head": rng.randi() % ANIMALS.size(),
		"front_legs": rng.randi() % ANIMALS.size(),
		"rear_legs": rng.randi() % ANIMALS.size(),
		"tail": rng.randi() % ANIMALS.size(),
		"diet": rng.randi() % DIETS.size(),
		"player_response": rng.randi() % RESPONSE.size(),
		"animal_response_similar": rng.randi() % RESPONSE.size(),
		"animal_response_different": rng.randi() % RESPONSE.size(),
	}
	return result

static func get_rng(_seed = null):
	var rng = RandomNumberGenerator.new()
	if _seed == null:
		rng.randomize()
	else: 
		rng.seed = _seed
	return rng
