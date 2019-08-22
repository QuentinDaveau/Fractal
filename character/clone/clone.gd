extends Character
class_name Clone

var _movement_dampening: float = 25.0

var zoom_position: Vector2 = Vector2(.0, .0)

var velocity_to_apply: Vector2 = Vector2(.0, .0)

var time_left: int = 0
var start_count: int = 0
var step_milis: int = 200

var _positions_array: Array = []
var cell_count: int = -1

var position_to_reach: Vector2 = Vector2.ZERO
var local_start_count: int = 0


func setup(properties: Dictionary) -> void:
	print(properties.replay)
	$ActionPlayer.set_actions_log(properties.replay)
	position = properties.position
	for body in _get_all_nodes($BodyParts, []):
		body.setup(properties)
	.setup(properties)


func _integrate_forces(state):
	if !_scale_init_done:
		_enable_pins(_get_all_pins($BodyParts, []))
		for body_part in _body_parts_list:
			body_part.enabled = true
		_scale_init_done = true

	_move_player_imm(state)
	._integrate_forces(state)


func _scale_self() -> void:
	_scale_init_done = false
	
	$AnimationManager.set_play_speed(_scale_coeff)
	$GrabArea/CollisionShape2D.get_shape().set_extents($GrabArea/CollisionShape2D.get_shape().get_extents() * _scale_coeff)
	
	_disable_pins(_get_all_pins($BodyParts, []))
	for pin in _get_all_pins($BodyParts, []):
		pin.position = _scale_vector(pin.position)

	$CollisionShape2D.get_shape().set_height(_scale_vector($CollisionShape2D.get_shape().get_height()))
	$CollisionShape2D.get_shape().set_radius(_scale_vector($CollisionShape2D.get_shape().get_radius()))
	$CollisionShape2D.position = _scale_vector($CollisionShape2D.position)
	$Sprite.scale = _scale_vector($Sprite.scale)
	$Sprite.position = _scale_vector($Sprite.position)
	mass = _scale_mass(mass)
	power = _scale_speed(power)
	brakePower = _scale_speed(brakePower)
	maxAppliableAngularV = _scale_speed(maxAppliableAngularV)
	gravity_scale = _scale_speed(gravity_scale)


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


func _move_player_imm(state: Physics2DDirectBodyState) -> void:

	if (time_left - (OS.get_ticks_msec() - start_count)) <= 10:
		return

	if (_positions_array.size() - 2) - (float(time_left - (OS.get_ticks_msec() - start_count))/step_milis) + 1 != cell_count:
		position_to_reach = _positions_array[(_positions_array.size() - 2) - (float(time_left - (OS.get_ticks_msec() - start_count))/step_milis) + 1]
		local_start_count = OS.get_ticks_msec()
		cell_count += 1

	if position_to_reach != Vector2.ZERO && _positions_array.size() > 0:
		var velocity_to_reach = (position_to_reach - global_position) * 1000 / (2 * step_milis - (OS.get_ticks_msec() - local_start_count))
		var velocity_to_add_x = velocity_to_reach.x - state.linear_velocity.x if abs(velocity_to_reach.x - state.linear_velocity.x) < _movement_dampening else _movement_dampening * sign(velocity_to_reach.x - state.linear_velocity.x)
		var velocity_to_add_y = velocity_to_reach.y - state.linear_velocity.y if abs(velocity_to_reach.y - state.linear_velocity.y) < _movement_dampening else _movement_dampening * sign(velocity_to_reach.y - state.linear_velocity.y)
		state.linear_velocity += Vector2(velocity_to_add_x, velocity_to_add_y)


func update_movement(new_position: Vector2, next_position: Vector2, delay: int, next_delay: int) -> void:

	if not next_delay:
		return

	var scaled_position = _get_scaled_position(new_position)
	var tmp_positions_array: Array = []
	var step = float(delay) / step_milis
	var dist_pos = scaled_position - global_position

	for i in range (step):
		tmp_positions_array.append(global_position + (dist_pos / step) * i)

	tmp_positions_array.append(scaled_position)
	tmp_positions_array.append(scaled_position + ((_get_scaled_position(next_position) - scaled_position) / (float(next_delay) / step_milis)))
	tmp_positions_array.append(scaled_position + (2 * (_get_scaled_position(next_position) - scaled_position) / ((float(next_delay) / step_milis))))

	_positions_array = tmp_positions_array
	cell_count = -1
	start_count = OS.get_ticks_msec()
	time_left = delay


func _get_scaled_position(position_to_scale: Vector2) -> Vector2:
	return zoom_position - ((zoom_position - position_to_scale) * _scale_coeff)