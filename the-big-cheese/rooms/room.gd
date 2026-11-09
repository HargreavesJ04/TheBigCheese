extends Node2D
class_name DungeonRoom

@export var door_up: bool = false
@export var door_right: bool = false
@export var door_down: bool = false
@export var door_left: bool = false

func get_doors() -> Array[bool]:
	return [
		door_up,
		door_right,
		door_down,
		door_left
	]
