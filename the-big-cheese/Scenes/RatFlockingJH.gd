extends CharacterBody2D

#Movement Parameters
@export var speed: float = 500.0
@export var max_force: float = 2000.0 #cap how sharply the boids can turn
@export var perceptionRadius: float = 450.0 #vision in pixels to search for other boids
@export var separationRadius: float = 300.0 #a boids "personal space" I guess in pixels 

#Steering Weights
@export var alignmentWeight: float = 1.5 #weight to steer toward the average heading of the flock
@export var cohesionWeight: float = 1.0 #weight to steeer to the average center position of the flock 
@export var separationWeight: float = 3.5 #weight to steer away from other boids 
@export var targetWeight: float = 2.5 #weight for seeking the target (player)

@onready var cheese: Node2D = get_node_or_null("../Player")


func _ready() -> void:
	if velocity == Vector2.ZERO: #if a boid is spawned in standing still this kciks them in a random direction at full speed
		velocity = Vector2.from_angle(randf() * TAU) * speed


func _physics_process(delta: float) -> void:
	var population: Array = get_tree().get_nodes_in_group("Boids")
	
	#calculate steering forces, maintain cruise speed and move
	velocity += _calculate_steering(population) * delta
	_enforce_cruise_speed()
	_move_and_bounce()

	if velocity.length_squared() > 0.0:
		rotation = velocity.angle()


#movement helpers



func _calculate_steering(population: Array) -> Vector2: #adds up alignment, cohesion, separation, and player chase into one force
	var total_steering := Vector2.ZERO
	total_steering += alignment(population) * alignmentWeight
	total_steering += cohesion(population) * cohesionWeight
	total_steering += separation(population) * separationWeight

	if cheese != null:
		total_steering += seek(cheese.global_position) * targetWeight
	#limit how hard the boids can turn per frame so turns look natural
	return total_steering.limit_length(max_force)

#prevents boids from slowing down and stopping when opposing forces push against each other
func _enforce_cruise_speed() -> void:
	var min_speed: float = speed * 0.75
	if velocity.length_squared() < 1.0:
		#if knocked completely still, push forward in whatever direction it is facing
		velocity = Vector2.RIGHT.rotated(rotation) * min_speed
	else:
		velocity = velocity.normalized() * clampf(velocity.length(), min_speed, speed)

#bounce the boids from a wall 
func _move_and_bounce() -> void:
	var pre_collision_velocity: Vector2 = velocity #stores previous velocity 
	move_and_slide()

	if get_slide_collision_count() == 0:
		return
	#combine contact angles so corners bounce diagonally instead of getting stuck
	var combined_normal := Vector2.ZERO
	for i in range(get_slide_collision_count()):
		combined_normal += get_slide_collision(i).get_normal()
	combined_normal = combined_normal.normalized()
	#only bounce if moving into the wall to prevent high-speed jitter	
	if pre_collision_velocity.dot(combined_normal) < 0.0:
		velocity = pre_collision_velocity.bounce(combined_normal)


#flocking and seeking


func steer_towards(desired_direction: Vector2) -> Vector2:
	var desired_velocity: Vector2 = desired_direction.normalized() * speed
	return desired_velocity - velocity

#steer away from nearby boids to avoid crowding
func separation(population: Array) -> Vector2:
	var avoidance_vector := Vector2.ZERO
	var neighbor_count: int = 0

	for boid in population:
		if boid != self:
			var dist: float = global_position.distance_to(boid.global_position)
			#push away if inside the boids separationRadius bubble 
			if dist > 0.0 and dist < separationRadius:
				avoidance_vector += (boid.global_position - global_position).normalized() / dist
				neighbor_count += 1

	if neighbor_count > 0:
		return steer_towards(-avoidance_vector)

	return Vector2.ZERO

#steer to match the average velocity of boids
func alignment(population: Array) -> Vector2:
	var avg_velocity := Vector2.ZERO
	var neighbor_count: int = 0

	for boid in population:
		if boid != self and global_position.distance_to(boid.global_position) < perceptionRadius:
			avg_velocity += boid.velocity
			neighbor_count += 1
	
	#steering
	if neighbor_count > 0:
		return steer_towards(avg_velocity / neighbor_count)

	return Vector2.ZERO

#steer towards the average position of nearby rats
func cohesion(population: Array) -> Vector2:
	var center_of_mass := Vector2.ZERO
	var neighbor_count: int = 0

	for boid in population:
		if boid != self and global_position.distance_to(boid.global_position) < perceptionRadius:
			center_of_mass += boid.global_position
			neighbor_count += 1

	if neighbor_count > 0:
		#calculate direction towards the center of mass
		var direction_to_center: Vector2 = (center_of_mass / neighbor_count) - global_position
		return steer_towards(direction_to_center)

	return Vector2.ZERO

#sterr directly towards the target position 
func seek(target_pos: Vector2) -> Vector2:
	return steer_towards(target_pos - global_position)
