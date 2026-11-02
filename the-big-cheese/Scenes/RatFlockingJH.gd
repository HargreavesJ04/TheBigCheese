extends Node2D

@export var speed: float = 500.0
@export var perceptionRadius: float = 200.0
@export var separationRadius: float = 100.0


@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 1.0
@export var separation_weight: float = 1.5

var velocity := Vector2.ZERO 
var moveRight: bool = true

@onready var character_body = $CharacterBody2D 
@onready var cheese = $"../Player"

func _ready() -> void:
	#if the boid spawns with 0 velocity give it a random direction
	if velocity == Vector2.ZERO:
		var random_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		velocity = random_direction * speed

func _physics_process(delta: float) -> void:
	
	var population = get_tree().get_nodes_in_group("Boids")
	
	#calculate steering forces 
	var align_force = alignment(population, null) * alignment_weight
	var cohes_force = calculate_cohesion(population, null) * cohesion_weight
	var separ_force = calculate_separation(population, null) * separation_weight
	
	#add forces to velocity
	velocity += (align_force + cohes_force + separ_force) * delta
	velocity = velocity.limit_length(speed)
	#movement 
	global_position += velocity * delta
	#rotate the rats
	if velocity.length() > 0: 
		rotation = velocity.angle()


func calculate_separation(population: Array, target_agent: Node2D) -> Vector2:
	var avoidance_vector := Vector2.ZERO
	var neighbor_count: int = 0
	
	for boid in population:
		if boid != self and boid != target_agent:
			if global_position.distance_to(boid.global_position) < separationRadius:
				avoidance_vector += (boid.global_position - global_position)
				neighbor_count += 1
				
	if neighbor_count > 0:
		avoidance_vector *= -1
		var desired_velocity: Vector2 = avoidance_vector.normalized() * speed
		return desired_velocity - velocity
		
	return Vector2.ZERO
	
func alignment(boidPopulation: Array, targetBoid: Node2D) -> Vector2:
	var avgVelocity = Vector2.ZERO
	var neighbourBoids: int = 0 
	
	for boid in boidPopulation: # Changed from 'boids' to 'boid'
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
		
func calculate_cohesion(population: Array, target_agent: Node2D) -> Vector2:
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Walls"):
		moveRight = false
		print("rat hit")
