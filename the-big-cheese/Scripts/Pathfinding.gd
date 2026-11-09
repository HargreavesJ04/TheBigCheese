#https://medium.com/@nicholas.w.swift/easy-a-star-pathfinding-7e6689c7f7b2

extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func Pathfind() -> void:
	
	#Pathfinding order:
		#Pathfind through rooms first.
		#When in each room, pathfind to nearest door to next room.
	#Pathfind to random location when not in range of player
	#Pathfind towards player (location updated every 5 seconds), when in rough range of the player.
	#Pathfind exctly to the player, if player is in sight/same room.
	
	#Take first cell position
	#A* to final position:
		#Keep a list of all prior searched cells, with costs applied.
		#Loop through all unsearched cells, and add cost.
		#Return the lowest cost path.
	#Return output path as an array of cells.
	
	#OpenList = []
	#ClosedList = []
	#OpenList.append(StartTile)
	#	
	#	While OpenList.size() > 0:
	#		OpenList.find(LowestFCell)
	#		ClosedList.append(LowestFCell)
	#		OpenList.remove(LowestFCell)
	#		CurrentCell = Cell
	#		for AdjacentCells:
	#			if (NotWalkable || ClosedList.find(Cell)):
	#				#ContinueLoop
	#			if (not OpenList.find(Cell)):
	#				OpenList.append(Cell)
	#				Cell.Parent = CurrentCell
	#			else:
	#				if GCost < OtherGCost:
	#					Cell.Parent = CurrentCell
	#					Recalc G & F scores
	#		if (ClosedList.find(TargetCell)):
	#			break
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
