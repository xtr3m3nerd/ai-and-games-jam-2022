extends Node2D

class_name PlayerRig

enum FACIAL_EXPRESSION { ANGRY, HAPPY, DEAD, HEARTBROKEN }
onready var expressions = {
	FACIAL_EXPRESSION.ANGRY: $Root/Polygons/Face1,
	FACIAL_EXPRESSION.HAPPY: $Root/Polygons/Face2,
	FACIAL_EXPRESSION.DEAD: $Root/Polygons/Face3,
	FACIAL_EXPRESSION.HEARTBROKEN: $Root/Polygons/Face4,
}

onready var basic_body = $Root/Polygons/BasicBody
onready var metal_body = $Root/Polygons/MetalBody
onready var broom = $Root/Polygons/Broom
onready var crowbar = $Root/Polygons/Crowbar
onready var signshield = $Root/Polygons/SignShield
onready var right_foot = $Root/Polygons/RightFoot
onready var left_foot = $Root/Polygons/LeftFoot
onready var right_wheel = $Root/Polygons/RightWheel
onready var left_wheel = $Root/Polygons/LeftWheel

enum UPGRADES { METALBODY, WHEELS, CROWBAR, SIGNSHIELD }

func _ready():
	pass # Replace with function body.

func change_expression(expression):
	for key in expressions.keys():
		expressions[key].hide()
	expressions[expression].show()

func upgrade_rig(upgrade):
	match(upgrade):
		UPGRADES.METALBODY:
			basic_body.hide()
			metal_body.show()
		UPGRADES.WHEELS:
			left_foot.hide()
			right_foot.hide()
			left_wheel.show()
			right_wheel.show()
		UPGRADES.CROWBAR:
			broom.hide()
			crowbar.show()
		UPGRADES.SIGNSHIELD:
			signshield.show()
