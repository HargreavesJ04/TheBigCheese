extends Node2D

var PosX: float
var PosY: float
var VolX: float
var VolY: float

var speed = 500;
var direction = Vector2.RIGHT
var moveRight = true


@onready var boids: Array = get_tree().get_nodes_in_group("Boids") #
@onready var cheese = "../Player" 
@onready var RatBody = $CharacterBody2D

func _ready() -> void:
	pass
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
	
	if moveRight == true:
		position += direction * speed * delta
	if moveRight == false:
		position -= direction * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Walls"):
		moveRight = false
		print("rat hit")
	
