class_name Pickable extends PhysicsScaler

signal is_on_position(pickable_path)

enum STATES {FREE, MAGNETIZED, PICKED}

export(float) var magnetization_power: float = 400.0
export(float) var magnetization_snap_dist: float = 10.0
export(float) var rotation_power: float = 100.0
export(float) var max_rotation_velocity_variation: float = 30.0
export(float) var max_rotation_velocity: float = 15.0

var _current_state = STATES.FREE
var _possessor: Character
var _magnet_node: Node2D
var _aimed_position: Vector2 = Vector2(0.0, 0.0)
var _previous_magnet_position: Vector2 = Vector2(0.0, 0.0)

func setup(properties: Dictionary) -> void:
	.setup(properties)
	_scale_speed(magnetization_power)
	_scale_vector(magnetization_snap_dist)
	_scale_speed(rotation_power)
	_scale_speed(max_rotation_velocity_variation)
	_scale_speed(max_rotation_velocity)


func _integrate_forces(state):
	
	if _current_state == STATES.FREE:
		return
	
	if _current_state == STATES.MAGNETIZED:
		
		_aimed_position = global_position + ($RightHandlePosition.position.rotated(global_rotation))
		var dist_vector = _magnet_node.global_position - _aimed_position
		
		if dist_vector.length() <= magnetization_snap_dist:
			state.set_transform(state.get_transform().translated(((2 * _magnet_node.global_position) -_aimed_position - _previous_magnet_position).rotated(-global_rotation)))
			emit_signal("is_on_position", get_path())
			_current_state = STATES.PICKED
			return
		
		state.linear_velocity = dist_vector.normalized() * ease(inverse_lerp(0, magnetization_power, dist_vector.length()), 0.008) * magnetization_power
		_previous_magnet_position = _magnet_node.global_position
	
	_set_rotation(state, _magnet_node.global_rotation + (PI/2))

func is_free() -> bool:
	if _current_state == STATES.FREE:
		return true
	return false

func pick(possessor: Character, item_manager, grab_point: Node2D) -> void:
	if not _current_state == STATES.FREE:
		return
	_possessor = possessor
	_update_collision_exceptions(true)
	_magnet_node = grab_point
	_previous_magnet_position = _magnet_node.global_position
	item_manager.connect("drop_item", self, "_drop", [], CONNECT_ONESHOT)
	_current_state = STATES.MAGNETIZED


func _drop() -> void:
	_update_collision_exceptions(false)
	_possessor = null
	_magnet_node = null
	_current_state = STATES.FREE


func _update_collision_exceptions(add: bool) -> void:
	
	if add:
		for body_part in _possessor.get_body_parts():
			body_part.add_collision_exception_with(self)
	else:
		for body_part in _possessor.get_body_parts():
			body_part.remove_collision_exception_with(self)


func _set_rotation(state: Physics2DDirectBodyState, aimed_rotation: float) -> void:
	
	var selfAngle = rotation
	
	var diffAngle = 0
	
	if(abs(aimed_rotation - selfAngle) > PI):
		var angSign = sign(aimed_rotation - selfAngle)
		diffAngle = (-PI*angSign)+((aimed_rotation - selfAngle)+(-PI*angSign))
	else:
		diffAngle = aimed_rotation - selfAngle
	
	var angular_velocity_to_aim = sign(diffAngle) * ease(inverse_lerp(0, 3.14, abs(diffAngle)), 0.3) * rotation_power
	
	if(abs(angular_velocity_to_aim) > max_rotation_velocity):
		angular_velocity_to_aim = max_rotation_velocity * sign(angular_velocity_to_aim)
	
	var velocity_variation = angular_velocity_to_aim - state.angular_velocity
	
	if abs(velocity_variation) > max_rotation_velocity_variation:
		velocity_variation = sign(velocity_variation) * max_rotation_velocity_variation
	
	state.angular_velocity += velocity_variation


func _scale_self() -> void:
	
	_scale_mass(mass)
	_scale_speed(gravity_scale)
	_scale_vector($Sprite.scale)
	
	_scale_vector($RightHandlePosition.position)
	_scale_vector($LeftHandlePosition.position)
	
	var shape: Shape2D = $CollisionShape2D.get_shape()
	
	if shape is CapsuleShape2D:
		_scale_vector(shape.height)
		_scale_vector(shape.radius)
		
	elif shape is CircleShape2D:
		_scale_vector(shape.radius)
		
	elif shape is RectangleShape2D:
		_scale_vector(shape.extents)
