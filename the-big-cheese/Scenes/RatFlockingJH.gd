extends Node2D

var PosX: float
var PosY: float
var VolX: float
var VolY: float


@onready var boids: Array = get_tree().get_nodes_in_group("Boids")

func _ready() -> void:
	
	for boid in boids:
		if boid != self: 
			print(boid.global_position)

func separation() -> void:
	pass
	
func alignment() -> void:
	pass

func cohesion() -> void:
	pass

func _process(delta: float) -> void:
	pass
