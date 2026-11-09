extends CharacterBody2D

#Movement Parameters
@export var speed: float = 500.0
@export var max_force: float = 2000.0
@export var perceptionRadius: float = 450.0
@export var separationRadius: float = 120.0

#Steering Weights
@export var alignmentWeight: float = 1.5
@export var cohesionWeight: float = 1.0
@export var separationWeight: float = 3.5
@export var targetWeight: float = 2.5

@onready var cheese: Node2D = get_node_or_null("../Player")


func _ready() -> void:
	if velocity == Vector2.ZERO:
		velocity = Vector2.from_angle(randf() * TAU) * speed


func _physics_process(delta: float) -> void:
	var population: Array = get_tree().get_nodes_in_group("Boids")

	velocity += _calculate_steering(population) * delta
	_enforce_cruise_speed()
	_move_and_bounce()

	if velocity.length_squared() > 0.0:
		rotation = velocity.angle()


#movement helpers

func _calculate_steering(population: Array) -> Vector2:
	var total_steering := Vector2.ZERO
	total_steering += alignment(population) * alignmentWeight
	total_steering += cohesion(population) * cohesionWeight
	total_steering += separation(population) * separationWeight

	if cheese != null:
		total_steering += seek(cheese.global_position) * targetWeight

	return total_steering.limit_length(max_force)


func _enforce_cruise_speed() -> void:
	var min_speed: float = speed * 0.75
	if velocity.length_squared() < 1.0:
		velocity = Vector2.RIGHT.rotated(rotation) * min_speed
	else:
		velocity = velocity.normalized() * clampf(velocity.length(), min_speed, speed)


func _move_and_bounce() -> void:
	var pre_collision_velocity: Vector2 = velocity
	move_and_slide()

	if get_slide_collision_count() == 0:
		return

	var combined_normal := Vector2.ZERO
	for i in range(get_slide_collision_count()):
		combined_normal += get_slide_collision(i).get_normal()
	combined_normal = combined_normal.normalized()

	if pre_collision_velocity.dot(combined_normal) < 0.0:
		velocity = pre_collision_velocity.bounce(combined_normal)


#flocking and seeking

func steer_towards(desired_direction: Vector2) -> Vector2:
	var desired_velocity: Vector2 = desired_direction.normalized() * speed
	return desired_velocity - velocity


func separation(population: Array) -> Vector2:
	var avoidance_vector := Vector2.ZERO
	var neighbor_count: int = 0

	for boid in population:
		if boid != self:
			var dist: float = global_position.distance_to(boid.global_position)
			if dist > 0.0 and dist < separationRadius:
				avoidance_vector += (boid.global_position - global_position).normalized() / dist
				neighbor_count += 1

	if neighbor_count > 0:
		return steer_towards(-avoidance_vector)

	return Vector2.ZERO


func alignment(population: Array) -> Vector2:
	var avg_velocity := Vector2.ZERO
	var neighbor_count: int = 0

	for boid in population:
		if boid != self and global_position.distance_to(boid.global_position) < perceptionRadius:
			avg_velocity += boid.velocity
			neighbor_count += 1

	if neighbor_count > 0:
		return steer_towards(avg_velocity / neighbor_count)

	return Vector2.ZERO


func cohesion(population: Array) -> Vector2:
	var center_of_mass := Vector2.ZERO
	var neighbor_count: int = 0

	for boid in population:
		if boid != self and global_position.distance_to(boid.global_position) < perceptionRadius:
			center_of_mass += boid.global_position
			neighbor_count += 1

	if neighbor_count > 0:
		var direction_to_center: Vector2 = (center_of_mass / neighbor_count) - global_position
		return steer_towards(direction_to_center)

	return Vector2.ZERO


func seek(target_pos: Vector2) -> Vector2:
	return steer_towards(target_pos - global_position)
