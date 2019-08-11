extends PhysicsScaler
class_name Projectile

func setup(properties: Dictionary) -> void:
	global_position = properties.spawn_global_position - ($SpawnOrigin.position * _scale_coeff)
	global_rotation = properties.spawn_global_rotation
	linear_velocity = properties.spawn_linear_velocity
	.setup(properties)
	

func _scale_self():
	
	mass *= pow(_scale_coeff, 5)
	gravity_scale /= _scale_coeff
	
	$Sprite.scale *= _scale_coeff
	
	var shape: Shape2D = $CollisionShape2D.get_shape()
	
	if shape is CapsuleShape2D:
		shape.set_height(shape.get_height() * _scale_coeff)
		shape.set_radius(shape.get_radius() * _scale_coeff)
		
	elif shape is CircleShape2D:
		shape.set_radius(shape.get_radius() * _scale_coeff)
		
	elif shape is RectangleShape2D:
		shape.set_extents(shape.get_extents() * _scale_coeff)
