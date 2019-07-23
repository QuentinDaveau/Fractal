extends PhysicsScaler
class_name Projectile

func init_projectile(spawn_global_position, spawn_global_rotation, spawn_linear_velocity, spawn_scale_coeff: float, spawn_speed_coeff: float, spawn_body_scale_mult: float, spawn_body_mass_mult: float, spawn_layer_array: Array, spawn_mask_array: Array):
	global_position = spawn_global_position - ($SpawnOrigin.position * scale_coeff * body_scale_mult)
	global_rotation = spawn_global_rotation
	linear_velocity = spawn_linear_velocity
	init_physics_scaler(spawn_scale_coeff, spawn_speed_coeff, spawn_body_scale_mult, spawn_body_mass_mult, spawn_layer_array, spawn_mask_array)
	

func _scale_self():
	
	mass *= pow(body_mass_mult * scale_coeff, 5)
	gravity_scale /= speed_coeff * speed_coeff * scale_coeff * scale_coeff
	
	$Sprite.scale *= scale_coeff * body_scale_mult
	
	var shape: Shape2D = $CollisionShape2D.get_shape()
	
	if shape is CapsuleShape2D:
		shape.set_height(shape.get_height() * scale_coeff * body_scale_mult)
		shape.set_radius(shape.get_radius() * scale_coeff * body_scale_mult)
		
	elif shape is CircleShape2D:
		shape.set_radius(shape.get_radius() * scale_coeff * body_scale_mult)
		
	elif shape is RectangleShape2D:
		shape.set_extents(shape.get_extents() * scale_coeff * body_scale_mult)
