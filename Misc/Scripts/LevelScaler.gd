extends Node2D
class_name LevelScaler

export(bool) var is_scaled: bool = false
export(Vector2) var zoom_position: Vector2 = Vector2(0.0, 0.0)

export(float) var level_scale: float = 1.0
export(float) var weight_coeff: float = 1.0

export(Array) var layer_array: Array
export(Array) var mask_array: Array

var _layers_length: int = 32


func _enter_tree():
	
	_define_layers()
	
	if !is_scaled:
		return
	
	_scale_bodies()


func _define_layers() -> void:
	
	for body in _get_all_bodies(self, []):
		
		if body is PhysicsBody2D:
		
			if body is PhysicsScaler:
				body.layer_array = layer_array
				body.mask_array = mask_array
				return
			
			for i in range(_layers_length):
				if layer_array.has(i):
					body.set_collision_layer_bit(i, true)
				else:
					body.set_collision_layer_bit(i, false)
			
			for i in range(_layers_length):
				if mask_array.has(i):
					body.set_collision_mask_bit(i, true)
				else:
					body.set_collision_mask_bit(i, false)


func _scale_bodies() -> void:
	
	for body in get_children():
		
		if body is Node2D:
		
			_set_body_position(body)
			
			if body is PhysicsScaler:
				body.scale_coeff = level_scale
				return
			
			if body is RigidBody2D:
				body.mass *= level_scale * weight_coeff
				body.gravity_scale /= level_scale
			
			_scale_body_children(body)


func _scale_body_children(body: Node2D) -> void:
	
	for children in body.get_children():
		
		children.position *= level_scale
		
		if children is CollisionShape2D:
			_scale_collision_shape(children)
		elif children is Sprite or children is Polygon2D:
			children.scale *= level_scale


func _get_all_bodies(node: Node, array:Array) -> Array:
	
	for N in node.get_children():
		if N is PhysicsBody2D:
			if N.get_child_count() > 0:
				array.append(N)
				array = _get_all_bodies(N, array)
			else:
				array.append(N)
	return array


func _scale_collision_shape(collision_shape: CollisionShape2D) -> void:
	
	var shape = collision_shape.get_shape()
	
	if shape is CapsuleShape2D:
		shape.set_height(shape.get_height() * level_scale)
		shape.set_radius(shape.get_radius() * level_scale)
		
	elif shape is CircleShape2D:
		shape.set_radius(shape.get_radius() * level_scale)
		
	elif shape is RectangleShape2D:
		shape.set_extents(shape.get_extents() * level_scale)


func _set_body_position(body: Node2D) -> void:
	body.position = _get_scaled_position(body.position)


func _get_scaled_position(position_to_scale: Vector2) -> Vector2:
	return zoom_position - ((zoom_position - position_to_scale) * level_scale)