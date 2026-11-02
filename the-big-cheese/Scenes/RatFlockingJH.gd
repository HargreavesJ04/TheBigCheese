extends CharacterBody2D

@export var speed: float = 500.0
@export var perceptionRadius: float = 200.0
@export var separationRadius: float = 100.0


@export var alignmentWeight: float = 2.0
@export var cohesionWeight: float = 2.0
@export var separationWeight: float = 3.0


var moveRight: bool = true

@onready var character_body = $"."
@onready var cheese = $"../Player"
@onready var uiSlider = "res://Scenes/UI/boid_ui.tscn"



func _ready() -> void:
	
	
	#if the boid spawns with 0 velocity give it a random direction
	if velocity == Vector2.ZERO:
		var randomDirection = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		velocity = randomDirection * speed

func _physics_process(delta: float) -> void:
	
	var population = get_tree().get_nodes_in_group("Boids")
	
	#calculate steering forces 
	var alignForce = alignment(population, null) * alignmentWeight
	var cohForce = cohesion(population, null) * cohesionWeight
	var sepForce = separation(population, null) * separationWeight
	
	#add forces to velocity
	var totalSteering = (alignForce + cohForce + sepForce)
	velocity += totalSteering * delta
	velocity = velocity.limit_length(speed)
	
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var wallNormal = collision.get_normal()
		velocity = velocity.bounce(wallNormal)	

	
	#rotate the rats
	if velocity.length() > 0: 
		rotation = velocity.angle()
		
	


func separation(population: Array, target_agent: CharacterBody2D) -> Vector2:
	var avoidanceVector := Vector2.ZERO
	var neighborCount: int = 0
	
	for boid in population:
		if boid != self and boid != target_agent:
			if global_position.distance_to(boid.global_position) < separationRadius:
				avoidanceVector += (boid.global_position - global_position)
				neighborCount += 1
				
	if neighborCount > 0:
		avoidanceVector *= -1
		var desiredVelocity: Vector2 = avoidanceVector.normalized() * speed
		return desiredVelocity - velocity
		
	return Vector2.ZERO
	
func alignment(boidPopulation: Array, targetBoid: CharacterBody2D) -> Vector2:
	var avgVelocity = Vector2.ZERO
	var neighbourBoids: int = 0 
	
	for boid in boidPopulation: 
		if boid != self and boid != targetBoid: 
			if global_position.distance_to(boid.global_position) < perceptionRadius:
				avgVelocity += boid.velocity
				neighbourBoids += 1

	if neighbourBoids > 0:
		avgVelocity /= neighbourBoids 
		avgVelocity = avgVelocity.normalized() * speed 
		var steering: Vector2 = avgVelocity - velocity
		return steering
		
	return Vector2.ZERO 
		
func cohesion(population: Array, target_agent: CharacterBody2D) -> Vector2:
	var center_of_mass := Vector2.ZERO
	var neighbor_count: int = 0
	
	for boid in population:
		if boid != self and boid != target_agent:
			if global_position.distance_to(boid.global_position) < perceptionRadius:
				center_of_mass += boid.global_position
				neighbor_count += 1
				
	if neighbor_count > 0:
		center_of_mass /= neighbor_count
		var direction_to_center: Vector2 = center_of_mass - global_position
		var desired_velocity: Vector2 = direction_to_center.normalized() * speed
		return desired_velocity - velocity
		
	return Vector2.ZERO
