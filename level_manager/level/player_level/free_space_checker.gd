extends Node2D

onready var _raycasts: Array = [$RayCast2D, $RayCast2D2, $RayCast2D3, $RayCast2D4, $RayCast2D5]


func check_free_space(check_position: Vector2) -> bool:
	position = check_position
	return _check_raycasts()


func set_shape(bound_box: Dictionary) -> void:
	for i in range(_raycasts.size()):
		_raycasts[i].cast_to = Vector2(0.0, bound_box.height)
		_raycasts[i].position.x = (i * bound_box.width / (_raycasts.size() - 1)) - (bound_box.width / 2) + bound_box.offset_x
		_raycasts[i].position.y = bound_box.offset_y - (bound_box.height / 2)
	$GroundRayCast.position = Vector2(bound_box.offset_x, bound_box.offset_y + (bound_box.height / 2))


func _check_raycasts() -> bool:
	$GroundRayCast.force_raycast_update()
	if not $GroundRayCast.is_colliding():
		return false
	for raycast in _raycasts:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			return false
	return true
