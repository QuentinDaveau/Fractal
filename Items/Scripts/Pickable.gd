class_name Pickable extends PhysicsScaler

signal is_on_position

onready var rightHandle: Position2D = $RightHandlePosition

export(float) var magnetization_power: float = 400.0
export(float) var magnetization_min_dist: float = 1.0
export(float) var magnetization_snap_dist: float = 10.0
export(float) var rotation_power: float = 100.0
export(float) var max_rotation_velocity_variation: float = 30.0
export(float) var max_rotation_velocity: float = 15.0

var is_picked: bool = false
var is_being_picked: bool = false

var _owner: Character

var _magnetized: bool = false
var _magnet_node: Node2D

var _aimed_position: Vector2 = Vector2(0.0, 0.0)
var _aimed_rotation: float = 0.0

var _previous_magnet_position: Vector2 = Vector2(0.0, 0.0)


func _integrate_forces(state):
	
	if is_picked:
		_aimed_rotation = _magnet_node.global_rotation + (PI/2)
		state = _set_rotation(state)
		return
	
	if !_magnetized:
		return

	if is_being_picked && _magnet_node != null:
		_aimed_position = global_position + (rightHandle.position.rotated(global_rotation))
		var dist_vector: Vector2 = _magnet_node.global_position - _aimed_position
		
		if dist_vector.length() <= magnetization_snap_dist:
			var t = state.get_transform()
			state.set_transform(t.translated(((_magnet_node.global_position - _aimed_position) + _magnet_node.global_position - _previous_magnet_position).rotated(-global_rotation)))
			emit_signal("is_on_position")
			_magnetized = false
			is_picked = true
			return
		
		_aimed_rotation = _magnet_node.global_rotation + (PI/2)
		state.linear_velocity = dist_vector.normalized() * ease(inverse_lerp(0, magnetization_power, dist_vector.length()), 0.008) * magnetization_power / (scale_coeff * speed_coeff)
		state = _set_rotation(state)
		
		_previous_magnet_position = _magnet_node.global_position


func pick(new_owner: Character, grab_point_node: Node2D) -> bool:
	if is_picked || is_being_picked:
		return false
	
	_owner = new_owner
	
	_update_collision_exceptions(true)
	_magnet_node = grab_point_node
	_magnetized = true
	
	is_being_picked = true
	
	_previous_magnet_position = _magnet_node.global_position
	
	return true


func drop() -> void:
	_update_collision_exceptions(false)
	_owner = null
	_magnetized = false
	_magnet_node = null
	is_picked = false
	is_being_picked = false


func _update_collision_exceptions(add: bool) -> void:
	
	if add:
		for body_part in _owner.get_body_parts():
			body_part.add_collision_exception_with(self)
	else:
		for body_part in _owner.get_body_parts():
			body_part.remove_collision_exception_with(self)


func _set_rotation(state: Physics2DDirectBodyState) -> Physics2DDirectBodyState:
	
	var selfAngle = rotation
	
	var diffAngle = 0
	
	if(abs(_aimed_rotation - selfAngle) > PI):
		var angSign = sign(_aimed_rotation - selfAngle)
		diffAngle = (-PI*angSign)+((_aimed_rotation - selfAngle)+(-PI*angSign))
	else:
		diffAngle = _aimed_rotation - selfAngle
	
	var angular_velocity_to_aim = sign(diffAngle) * ease(inverse_lerp(0, 3.14, abs(diffAngle)), 0.3) * rotation_power / (speed_coeff * scale_coeff * scale_coeff)
	
	if(abs(angular_velocity_to_aim) > max_rotation_velocity):
		angular_velocity_to_aim = max_rotation_velocity * sign(angular_velocity_to_aim)
	
	var velocity_variation = angular_velocity_to_aim - state.angular_velocity
	
	if abs(velocity_variation) > max_rotation_velocity_variation / (speed_coeff * scale_coeff):
		velocity_variation = sign(velocity_variation) * max_rotation_velocity_variation / (speed_coeff * scale_coeff)
	
	state.angular_velocity += velocity_variation
	
	return state


func _scale_self() -> void:
	
	mass *= pow(scale_coeff, 2) * body_mass_mult
	gravity_scale /= scale_coeff * scale_coeff * body_mass_mult
	
	$Sprite.scale *= scale_coeff * body_scale_mult
	
	$RightHandlePosition.position *= scale_coeff * body_scale_mult
	$LeftHandlePosition.position *= scale_coeff * body_scale_mult
	
	var shape: Shape2D = $CollisionShape2D.get_shape()
	
	if shape is CapsuleShape2D:
		shape.set_height(shape.get_height() * scale_coeff * body_scale_mult)
		shape.set_radius(shape.get_radius() * scale_coeff * body_scale_mult)
		
	elif shape is CircleShape2D:
		shape.set_radius(shape.get_radius() * scale_coeff * body_scale_mult)
		
	elif shape is RectangleShape2D:
		shape.set_extents(shape.get_extents() * scale_coeff * body_scale_mult)
