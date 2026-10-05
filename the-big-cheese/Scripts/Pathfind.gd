class_name Pathfinding
extends Node

func PathfindToPoint(EndPos: Vector2, StartPos: ):
	var Endpoints: PackedVector2Array
	
	#If cell based, do per-cell,
	#If free form, do nodal: https://www.reddit.com/r/Unity2D/comments/31f8ns/nodal_pathfinding_in_unity_2d_with_a_in_non_grid/
	#	Divide world into grid tiles - Every tile with any overlap is not pathable.
	#	Pathing is more precice a short dist around the agent.
	
	return Endpoints
