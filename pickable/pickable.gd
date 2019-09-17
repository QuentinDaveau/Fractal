class_name Pickable extends PhysicsScaler

signal is_on_position(pickable_path)

enum STATES {FREE, MAGNETIZED, PICKED}

var ROTATION_POWER: float = 100.0
var MAX_ROTATION_ACCELERATION: float = 30.0
var MAX_ROTATION_VELOCITY: float = 15.0

var TELEPORT_DELAY: float = 1.0

var _state = STATES.FREE
var _possessor: Character

var _magnet_node: Node2D

var _teleport: bool = false
var _teleport_position: Vector2


func setup(properties: Dictionary) -> void:
	.setup(properties)


func _ready() -> void:
	$TeleportTimer.connect("timeout", self, "_teleport_delay_timeout")


func _integrate_forces(state) -> void:
	if _state == STATES.PICKED:
		_set_rotation(state, _magnet_node.global_rotation + PI/2)
	if _teleport:
		var aimed_position = global_position + ($RightHandlePosition.position.rotated(global_rotation))
		state.set_transform(state.get_transform().translated(
		(_magnet_node.global_position - aimed_position).rotated(- global_rotation)))
		emit_signal("is_on_position", get_path())
		_state = STATES.PICKED
		_teleport = false


func is_free() -> bool:
	if _state == STATES.FREE:
		return true
	return false


func is_picked() -> bool:
	if _state == STATES.PICKED:
		return true
	return false


func pick(possessor: Character, item_manager, grab_point: Node2D, teleport_delay: float = TELEPORT_DELAY) -> void:
	if not _state == STATES.FREE:
		return
	_possessor = possessor
	_magnet_node = grab_point
	item_manager.connect("drop_item", self, "_drop", [], CONNECT_ONESHOT)
	_state = STATES.MAGNETIZED
	$TeleportTimer.start(teleport_delay)


func _teleport_delay_timeout() -> void:
	if not _state == STATES.MAGNETIZED:
		return
	_update_collision_exceptions(true)
	_teleport = true


func _scale_self() -> void:
	
	ROTATION_POWER = _scale_speed(ROTATION_POWER)
	MAX_ROTATION_ACCELERATION = _scale_speed(MAX_ROTATION_ACCELERATION)
	MAX_ROTATION_VELOCITY = _scale_speed(MAX_ROTATION_VELOCITY)
	TELEPORT_DELAY = _scale_speed(TELEPORT_DELAY)
	
	mass = _scale_mass(mass)
	gravity_scale = _scale_speed(gravity_scale)
	
	$RightHandlePosition.position = _scale_vector($RightHandlePosition.position)
	$LeftHandlePosition.position = _scale_vector($LeftHandlePosition.position)
	
	var vertex_buffer: = []
	for vertex in $CollisionPolygon2D.polygon:
		vertex_buffer.append(_scale_vector(vertex))
	$CollisionPolygon2D.set_polygon(vertex_buffer)


func _drop(item_manager) -> void:
	_update_collision_exceptions(false)
	_possessor = null
	_magnet_node = null
	_state = STATES.FREE


func _update_collision_exceptions(add: bool) -> void:
	
	if add:
		for body_part in _possessor.get_body_parts():
			body_part.add_collision_exception_with(self)
	else:
		for body_part in _possessor.get_body_parts():
			body_part.remove_collision_exception_with(self)


func _set_rotation(state: Physics2DDirectBodyState, aimed_rotation: float) -> void:

	var diffAngle = 0
	
	if(abs(aimed_rotation - rotation) > PI):
		var angSign = sign(aimed_rotation - rotation)
		diffAngle = (-PI*angSign)+((aimed_rotation - rotation)+(-PI*angSign))
	else:
		diffAngle = aimed_rotation - rotation
	
	var angular_velocity_to_aim = sign(diffAngle) * ease(inverse_lerp(0, 3.14, abs(diffAngle)), 0.3) * ROTATION_POWER
	
	if(abs(angular_velocity_to_aim) > MAX_ROTATION_VELOCITY):
		angular_velocity_to_aim = MAX_ROTATION_VELOCITY * sign(angular_velocity_to_aim)
	
	var velocity_variation = angular_velocity_to_aim - state.angular_velocity
	
	if abs(velocity_variation) > MAX_ROTATION_ACCELERATION:
		velocity_variation = sign(velocity_variation) * MAX_ROTATION_ACCELERATION
	
	state.angular_velocity += velocity_variation
