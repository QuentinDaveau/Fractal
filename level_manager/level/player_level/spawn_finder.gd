extends Node

"""
The spawn finder finds correct places to spawn the players and the items (with plateform under spawnpoint, sufficient place)
"""

var PLAYER_BOUNDS: Dictionary = {"top": 100.0, "bottom": 100.0}
var ITEM_BOUNDS: Dictionary = {"top": 100.0, "bottom": 100.0}

var TEMP_SIZE: Vector2 = Vector2(1000.0, 500.0)


func find_spawn_position(spawnable: Spawnable) -> Vector2:
	var coords = Vector2(rand_range(0.0, TEMP_SIZE.x), rand_range(0.0, TEMP_SIZE.y))
	
	$FreeSpaceChecker.set_shape(spawnable.get_bound_box())
	randomize()
	
	while not ($FreeSpaceChecker.check_free_space(coords)):
		coords = Vector2(rand_range(0.0, TEMP_SIZE.x), rand_range(0.0, TEMP_SIZE.y))
	return coords