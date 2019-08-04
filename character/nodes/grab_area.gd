extends Area2D

func find_closest_item(grab_point_position: Vector2) -> Pickable:
	var closest_body: Pickable
	for body in get_overlapping_bodies():
		if body is Pickable:
			if body.is_free():
				if closest_body == null:
					closest_body = body
				else:
					if grab_point_position.distance_to(body.global_position) < grab_point_position.distance_to(closest_body.global_position):
						body = closest_body
	return closest_body