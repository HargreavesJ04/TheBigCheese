
extends Node2D

@export var room_scenes: Array[PackedScene] = []
@export var room_size: Vector2i = Vector2i(2880, 3040)
@export var dungeon_width: int = 6
@export var dungeon_height: int = 6
@export var max_rooms: int = 15
@export var generation_attempts: int = 1000

const DIRECTIONS = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT
]

var room_types: Array[Dictionary] = []
var grid: Dictionary = {}


func _ready() -> void:
	randomize()
	load_room_types()
	generate_dungeon()


func load_room_types() -> void:
	room_types.clear()

	for scene in room_scenes:
		if scene == null:
			continue

		var room = scene.instantiate()

		if room is DungeonRoom:
			room_types.append({
				"scene": scene,
				"doors": room.get_doors()
			})

		room.free()


func generate_dungeon() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	grid.clear()

	if room_types.is_empty():
		push_error("No valid room scenes assigned.")
		return

	if dungeon_width < 1 or dungeon_height < 1:
		return

	var target = mini(max_rooms, dungeon_width * dungeon_height)

	if target < 2:
		return

	var best_path: Array[Vector2i] = []

	for attempt in range(generation_attempts):
		var path: Array[Vector2i] = [Vector2i.ZERO]
		var visited: Dictionary = {Vector2i.ZERO: true}

		while path.size() < target:
			var current = path.back()
			var choices: Array[Vector2i] = []

			for direction in DIRECTIONS:
				var next_pos = current + direction

				if not is_inside_grid(next_pos):
					continue

				if visited.has(next_pos):
					continue

				choices.append(next_pos)

			if choices.is_empty():
				break

			var next_pos: Vector2i = choices.pick_random()
			path.append(next_pos)
			visited[next_pos] = true

		if path.size() > best_path.size():
			best_path = path.duplicate()

		if best_path.size() == target:
			break

	for i in range(best_path.size()):
		var pos = best_path[i]
		var doors: Array[bool] = [false, false, false, false]

		if i > 0:
			var previous = best_path[i - 1]
			doors[direction_between(pos, previous)] = true

		if i < best_path.size() - 1:
			var next_pos = best_path[i + 1]
			doors[direction_between(pos, next_pos)] = true

		grid[pos] = doors

	for pos in grid:
		place_room(pos)


func direction_between(from: Vector2i, to: Vector2i) -> int:
	var difference = to - from

	for i in range(4):
		if DIRECTIONS[i] == difference:
			return i

	return -1


func doors_match(a: Array, b: Array) -> bool:
	for i in range(4):
		if a[i] != b[i]:
			return false

	return true


func place_room(pos: Vector2i) -> void:
	var required_doors: Array = grid[pos]
	var compatible: Array[Dictionary] = []

	for room_type in room_types:
		if doors_match(room_type["doors"], required_doors):
			compatible.append(room_type)

	if compatible.is_empty():
		push_warning("No matching room for doors: " + str(required_doors))
		return

	var chosen = compatible.pick_random()
	var room = chosen["scene"].instantiate()

	add_child(room)

	room.position = Vector2(
		pos.x * room_size.x,
		pos.y * room_size.y
	)
	

func is_inside_grid(pos: Vector2i) -> bool:
	return (
		pos.x >= 0
		and pos.y >= 0
		and pos.x < dungeon_width
		and pos.y < dungeon_height
	)
