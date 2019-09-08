extends PhysicsScaler
class_name PhysicProjectile

func setup(properties: Dictionary) -> void:
	.setup(properties)
	global_position = properties.global_position - (_scale_vector($SpawnOrigin.position)).rotated(properties.global_rotation)
	global_rotation = properties.global_rotation
	linear_velocity = Vector2(_scale_vector(_scale_speed(properties.linear_velocity)), 0).rotated(properties.global_rotation)


func _scale_self():
	print(linear_velocity.length())
	
	mass = _scale_mass(mass)
	gravity_scale = _scale_speed(_scale_power(gravity_scale))
	
	$Sprite.scale = _scale_vector($Sprite.scale)
	
	var vertex_buffer: = []
	for vertex in $CollisionPolygon2D.polygon:
		vertex_buffer.append(_scale_vector(vertex))
	$CollisionPolygon2D.set_polygon(vertex_buffer)
