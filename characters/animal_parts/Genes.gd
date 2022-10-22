extends Node

class_name Genes

enum GENES { hippo, giraffe, penguin, cheetah, potato, carrot, cheeto, avocado }
enum DIETS { HERBIVORE, OMNIVORE, CARNIVORE }
enum RESPONSE { AGRESSIVE, FEARFUL, CURIOUS, NONE }
enum RESPONSE_RANGE { ALL, SIMILAR, DIFFERENT }

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

var genes = {
	"body": GENES.potato,
	"head": GENES.hippo,
	"front_legs": GENES.hippo,
	"rear_legs": GENES.hippo,
	"tail": GENES.hippo,
	"diet": DIETS.HERBIVORE,
	"player_response": RESPONSE.AGRESSIVE,
	"animal_response_similar": RESPONSE.CURIOUS,
	"animal_response_different": RESPONSE.FEARFUL,
}

func breed_genes(parentA, parentB):
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

func compare_genes(A, B):
	var combined_genes = A.merge(B)
	var total = combined_genes.keys().size()
	var count = 0
	for key in combined_genes.keys():
		if A.get(key) == B.get(key):
			count += 1
	return count/total


func build_from_genes(genes):
	#Build Body
	var body = genes.get("body")
	if body == null:
		print("Failed to make animal because no body")
		return
