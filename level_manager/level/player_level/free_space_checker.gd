extends Area2D

func set_shape(bound_box: Dictionary) -> void:
	$CollisionShape2D.shape.set_extents(Vector2(bound_box.width, bound_box.height))
	$CollisionShape2D.position = Vector2(bound_box.offset_x, bound_box.offset_y)
	$RayCast2D.position = Vector2(bound_box.offset_x, bound_box.offset_y + (bound_box.height / 2))
