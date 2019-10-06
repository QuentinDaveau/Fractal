extends Character
class_name Clone

var _movement_dampening: float = 100.0

var ZOOM_POSITION: Vector2 = Vector2(.0, .0)

var velocity_to_apply: Vector2 = Vector2(.0, .0)

var time_left: int = 0
var start_count: int = 0
var step_milis: int = 200

var _positions_array: Array = []
var cell_count: int = -1

var _position_to_reach: Vector2 = Vector2.ZERO
var local_start_count: int = 0

var _acceleration: float = 600.0


func setup(properties: Dictionary) -> void:
	.setup(properties)
	$ActionPlayer.set_actions_log(properties.replay)
	$ActionPlayer.LEVEL_WAREHOUSE = properties.level_warehouse
	ZOOM_POSITION = properties.zoom_position
	$Properties.DEVICE_ID = properties.device_id
	
	for body in _get_all_nodes($BodyParts, []):
		body.setup(properties)
	


func _integrate_forces(state):
	if !_scale_init_done:
		_enable_pins(_get_all_pins($BodyParts, []))
		for body_part in _body_parts_list:
			body_part.enabled = true
		_scale_init_done = true

	_move_clone(state)
	._integrate_forces(state)


func update_movement(new_position: Vector2) -> void:
	_position_to_reach = _get_scaled_position(new_position)
	$Sprite.global_position = _position_to_reach


func _scale_self() -> void:
	_scale_init_done = false
	
	$ActionPlayer.set_replay_speed(1/_scale_speed(1.0))
	_movement_dampening = _scale_speed(_movement_dampening)
	
	$AnimationManager.set_play_speed(1/_scale_speed(1.0))
#	$GrabArea/CollisionShape2D.get_shape().set_extents($GrabArea/CollisionShape2D.get_shape().get_extents() * _scale_coeff)
	
	_disable_pins(_get_all_pins($BodyParts, []))
	for pin in _get_all_pins($BodyParts, []):
		pin.position = _scale_vector(pin.position)

	var vertex_buffer: = []
	for vertex in $CollisionPolygon2D.polygon:
		vertex_buffer.append(_scale_vector(vertex))
	$CollisionPolygon2D.set_polygon(vertex_buffer)
	
	mass = _scale_mass(mass)
	power = _scale_speed(power)
	brakePower = _scale_speed(brakePower)
	maxAppliableAngularV = _scale_speed(maxAppliableAngularV)
#	gravity_scale = 0


func _disable_pins(pins: Array) -> void:
	for pin in pins:
		_pins_list[pin.get_name()] = [pin.get_node_a(), pin.get_node_b()]
		pin.set_node_a("")
		pin.set_node_b("")


func _enable_pins(pins: Array) -> void:
	for pin in _get_all_pins($BodyParts, []):
		pin.set_node_a(_pins_list[pin.get_name()][0])
		pin.set_node_b(_pins_list[pin.get_name()][1])


func _get_all_pins(node:Node, array:Array) -> Array:
	for N in node.get_children():
		if N.is_class("PinJoint2D"):
			array.append(N)
		if N.get_child_count() > 0:
			array = _get_all_pins(N, array)
	return array


func _move_clone(state: Physics2DDirectBodyState) -> void:
	if _position_to_reach != Vector2.ZERO:
		var velocity_to_reach_x = sign(_position_to_reach.x - global_position.x) * ease(inverse_lerp(0, _acceleration, abs(_position_to_reach.x - global_position.x)), 0.2) * _acceleration
		var velocity_to_reach_y = sign(_position_to_reach.y - global_position.y) * ease(inverse_lerp(0, _acceleration, abs(_position_to_reach.y - global_position.y)), 0.2) * _acceleration
		
		state.linear_velocity = Vector2(velocity_to_reach_x, velocity_to_reach_y)


func _get_scaled_position(position_to_scale: Vector2) -> Vector2:
	return ZOOM_POSITION - ((ZOOM_POSITION - position_to_scale) * _scale_coeff)