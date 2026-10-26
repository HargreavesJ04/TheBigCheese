extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func Pathfind() -> void:
	#Take first cell position
	#A* to final position:
		#Keep a list of all prior searched cells, with costs applied.
		#Loop through all unsearched cells, and add cost.
		#Return the lowest cost path.
	#Return output path as an array of cells.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
