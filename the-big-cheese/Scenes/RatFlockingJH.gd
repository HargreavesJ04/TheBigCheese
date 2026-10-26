extends Node2D

@export var speed = 500;
var velocity = Vector2.ZERO	

var direction = Vector2.RIGHT
var moveRight = true



@onready var boids = $CharacterBody2D
@onready var cheese = "../Player" 
  
 

func _ready() -> void:
	pass	
	

func separation() -> void:
	pass
	
func alignment(boidPopulation: Array, targetBoid: Node2D) -> Vector2:
	
	var avgVelocity = Vector2.ZERO
	var neighbourBoids: int = 0 
	
	if boids != self and boids != targetBoid: 
		if global_position.distance_to(boids.global_position) < 200:
			avgVelocity.x += boids.velocity.x
			avgVelocity.y += boids.velocity.y
			neighbourBoids += 1

#steering boids 
	if neighbourBoids > 0:
		avgVelocity /= neighbourBoids 
		
		avgVelocity = avgVelocity.normalized() * speed 
		
		var steering: Vector2 = avgVelocity - velocity
		return steering
		
	return Vector2.ZERO
		
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
	
