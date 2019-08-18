extends Character
class_name Clone













var _movement_dampening: float = 25.0

var desired_position:Vector2 = Vector2(.1234, .1234)

var zoom_position: Vector2 = Vector2(.0, .0)

var velocity_to_apply: Vector2 = Vector2(.0, .0)

var time_left: int = 0
var start_count: int = 0
var step_milis: int = 200

var positions_array: Array = []
var cell_count: int = -1

var position_to_reach: Vector2 = Vector2.ZERO
var local_start_count: int = 0


func setup(properties: Dictionary) -> void:
	$ActionPlayer.set_actions_log(properties.replay)
	position = properties.position
	.setup(properties)


func _scale_self() -> void:
	_scale_init_done = false
	
	$AnimationManager.set_play_speed(_scale_coeff)
	
	$BodyParts/ArmTop/ArmBottom/RightGrabPoint.position = _scale_vector($BodyParts/ArmTop/ArmBottom/RightGrabPoint.position)
	$BodyParts/ArmTop2/ArmBottom2/LeftGrabPoint.position = _scale_vector($BodyParts/ArmTop2/ArmBottom2/LeftGrabPoint.position)
	
	$GrabArea/CollisionShape2D.get_shape().set_extents($GrabArea/CollisionShape2D.get_shape().get_extents() * _scale_coeff)
	
	movement_acceleration /= pow(_scale_coeff, 2)
	
	print(movement_acceleration)
	
	_disable_pins(_get_all_pins($BodyParts, []))
	
	for pin in _get_all_pins($BodyParts, []):

		pin.position *= _scale_coeff
	
#	for body_part in _get_all_nodes($BodyParts, _body_parts_list):
		
#		body_part.enabled = false
#
#		var body_part_collision_shape = body_part.get_node("./CollisionShape2D").get_shape()
#
#		if body_part_collision_shape is CapsuleShape2D:
#			body_part_collision_shape.set_height(body_part_collision_shape.get_height() * _scale_coeff)
#			body_part_collision_shape.set_radius(body_part_collision_shape.get_radius() * _scale_coeff)
#
#		if body_part_collision_shape is CircleShape2D:
#			body_part_collision_shape.set_radius(body_part_collision_shape.get_radius() * _scale_coeff)
#
#		body_part.get_node("./CollisionShape2D").position *= _scale_coeff
#
#		body_part.get_node("Sprite").scale *= _scale_coeff
#		body_part.get_node("Sprite").position *= _scale_coeff
#
#		body_part.mass *= _scale_coeff
#		body_part.power /= _scale_coeff * _scale_coeff
#		body_part.brakePower /= _scale_coeff * _scale_coeff
#		body_part.maxAppliableAngularV /= _scale_coeff * _scale_coeff
#
#		if body_part != self:
#			body_part.position *= _scale_coeff
#
#		body_part.gravity_scale = 0



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


#func jump(strength: float, held_strength: float) -> void:
#	jumping_strength = strength
#	jumping_held_strength = held_strength
#	jumping = true
#	jumping_held = true
#
#
#func release_jump() -> void:
#	jumping_held = false
#
#
func _integrate_forces(state):

	if !_scale_init_done:
		_enable_pins(_get_all_pins($BodyParts, []))
		for body_part in _body_parts_list:
			body_part.gravity_scale = _starting_gravity_scale / (_scale_coeff * _scale_coeff)
			body_part.enabled = true
		_scale_init_done = true

#	if !enabled:
#		return

#	applied_force.x = 0.0
#
#	add_central_force(Vector2(forceVector.x, 0.0))

#	state.linear_velocity.x = forceVector.x
#	_move_player(state)
#	_move_player_forces(state)

	_move_player_imm(state)
	._integrate_forces(state)

#	if jumping:
#		apply_central_impulse(Vector2(0.0,jumping_strength - (linear_velocity.y * 7)))
#		jumping = false


#	if jumping_held:
#		applied_force.y = jumping_held_strength
#	else:
#		applied_force.y = 0

#	$RayCast2D.global_rotation = 0.0

#	state.linear_velocity.x = 200
#	if raycast.is_colliding():
#		gravity_scale = 1

#	_keep_body_straight(state)



func _move_player_imm(state: Physics2DDirectBodyState) -> void:

	if (time_left - (OS.get_ticks_msec() - start_count)) <= 10:
		return

	if (positions_array.size() - 2) - ((time_left - (OS.get_ticks_msec() - start_count))/step_milis) + 1 != cell_count:

		position_to_reach = positions_array[(positions_array.size() - 2) - ((time_left - (OS.get_ticks_msec() - start_count))/step_milis) + 1]
#		print((positions_array.size() - 2) - ((time_left - (OS.get_ticks_msec() - start_count))/step_milis))
		local_start_count = OS.get_ticks_msec()
		cell_count += 1

	if position_to_reach != Vector2.ZERO && positions_array.size() > 0:
#		var velocity_to_reach = (_get_scaled_position(desired_position) - global_position) * 1000 / (time_left - (OS.get_ticks_msec() - start_count))

		var velocity_to_reach = (position_to_reach - global_position) * 1000 / (2 * step_milis - (OS.get_ticks_msec() - local_start_count))

#		var velocity_to_reach = (position_to_reach - global_position) * 1000 / (time_left - (OS.get_ticks_msec() - start_count))

#		print(positions_array.size(), "     ", (positions_array.size() - 3) - ((time_left - (OS.get_ticks_msec() - start_count))/step_milis) + 2, "      ", position_to_reach,"      ", global_position, "    ", velocity_to_reach)

#		print(velocity_to_reach, "   ", (time_left - (OS.get_ticks_msec() - start_count)), "      ", _get_scaled_position(desired_position), "    ", global_position )
		var velocity_to_add_x = velocity_to_reach.x - state.linear_velocity.x if abs(velocity_to_reach.x - state.linear_velocity.x) < _movement_dampening else _movement_dampening * sign(velocity_to_reach.x - state.linear_velocity.x)
		var velocity_to_add_y = velocity_to_reach.y - state.linear_velocity.y if abs(velocity_to_reach.y - state.linear_velocity.y) < _movement_dampening else _movement_dampening * sign(velocity_to_reach.y - state.linear_velocity.y)
		state.linear_velocity += Vector2(velocity_to_add_x, velocity_to_add_y)
#
##		if velocity_to_reach.length() > 100:
##			print(velocity_to_reach, "   ", (time_left - (OS.get_ticks_msec() - start_count)), "      ", _get_scaled_position(desired_position), "    ", global_position )
#
#
##	var acceleration = velocity_to_apply - state.linear_velocity
##
##	if abs(acceleration.x) > movement_acceleration:
##		acceleration.x = movement_acceleration * sign(acceleration.x)
##
##	if abs(acceleration.y) > movement_acceleration:
##		acceleration.y = movement_acceleration * sign(acceleration.y)
##
##	state.linear_velocity += acceleration
#
##		print(acceleration, "   ", movement_acceleration)
#
##		state.linear_velocity = velocity_to_apply
#
#	if desired_position != Vector2(.1234, .1234):
##		print(zoom_position, "   ", _get_scaled_position(desired_position), "    ", global_position)
#		state.linear_velocity = _get_scaled_position(desired_position) - global_position


func update_movement(new_position: Vector2, next_position: Vector2, delay: int, next_delay: int) -> void:

	var new_position2 = _get_scaled_position(new_position)
	
	print(new_position2)

	var test_array: Array = []
	var step = delay / step_milis
	var dist_pos = new_position2 - global_position

	for i in range (step):
		test_array.append(global_position + (dist_pos / step) * i)

#	if delay % step_milis != 0:
#		print(delay % step_milis)
#		test_array.append(dist_pos - (dist_pos * (delay - delay % step_milis)))

	test_array.append(new_position2)
	test_array.append(new_position2 + ((_get_scaled_position(next_position) - new_position2) / (next_delay / step_milis)))
	test_array.append(new_position2 + (2 * (_get_scaled_position(next_position) - new_position2) / ((next_delay / step_milis))))

	print(test_array, "   ", step, "   ", dist_pos, "    ", new_position2, "   ", global_position, "    ", delay,"   ", next_delay)

	positions_array = test_array
	cell_count = -1

	start_count = OS.get_ticks_msec()
	time_left = delay
	desired_position = new_position

#	if delay > 1:
#		velocity_to_apply = (_get_scaled_position(new_position) - global_position) * 1000 / delay
#		print(velocity_to_apply,"   ", global_position - new_position,"   ",  delay)

#
func _get_scaled_position(position_to_scale: Vector2) -> Vector2:
	return zoom_position - ((zoom_position - position_to_scale) * _scale_coeff)
#
#
#func _move_player(state: Physics2DDirectBodyState) -> void:
#
#	var current_velocity = state.linear_velocity.x
#	var desired_velocity = forceVector.x
#
#	if current_velocity == desired_velocity:
#		return
#
#	var acceleration = desired_velocity - current_velocity
#
#	if abs(current_velocity) < abs(desired_velocity):
#		if abs(acceleration) < movement_acceleration:
#			current_velocity += acceleration
#		else:
#			current_velocity += movement_acceleration * sign(acceleration)
#
##	print(current_velocity)
#
#	if abs(current_velocity) > _movement_dampening:
#		current_velocity -= _movement_dampening * sign(state.linear_velocity.x)
#	else:
#		current_velocity = 0.0
#
#	state.linear_velocity.x = current_velocity
#
#
#func _move_player_forces(state: Physics2DDirectBodyState) -> void:
#
#	applied_force.x = 0.0
#
#	var current_velocity = linear_velocity.x
#	var desired_velocity = forceVector.x
#
#	if abs(current_velocity) < abs(desired_velocity):
#		add_central_force(Vector2(inverse_lerp(0, desired_velocity, desired_velocity - current_velocity) * movement_acceleration * sign(desired_velocity), .0))
#
#	if abs(current_velocity) > _movement_dampening/200:
#		add_central_force(Vector2(-_movement_dampening * 20 * sign(current_velocity), .0))
#
##	print(inverse_lerp(0, desired_velocity, desired_velocity - current_velocity) * movement_acceleration * sign(desired_velocity))
#
#
#func _keep_body_straight(state: Physics2DDirectBodyState) -> void:
#
#	var targetAngle = targetNode.rotation
#	var selfAngle = global_rotation
#	var current_velocity = state.angular_velocity
#	var diffAngle = 0
#
#	if(abs(targetAngle - selfAngle) > PI):
#		var angSign = sign(targetAngle - selfAngle)
#		diffAngle = (-PI*angSign)+((targetAngle - selfAngle)+(-PI*angSign))
#	else:
#		diffAngle = targetAngle - selfAngle
#
#	var angularVToAim = sign(diffAngle) * ease(inverse_lerp(0, 3.14, abs(diffAngle)), 0.1) * power
#
#	if(sign(angularVToAim) != sign(angular_velocity)):
#		angularVToAim += brakePower * (abs(abs(angularVToAim) - abs(angular_velocity))) * sign(angularVToAim)
#
#	if(abs(angularVToAim) > maxAppliableAngularV):
#		angularVToAim = maxAppliableAngularV * sign(angularVToAim)
#
##	print("Différence angle: ",diffAngle,", Torque désiré: ",angularVToAim,", Torque réel: ",applied_torque)
#
#	if(current_velocity < angularVToAim):
#
#		var tempVelocity = angularVToAim - current_velocity
#
#		if tempVelocity > maxAppliedTorque:
#			tempVelocity = maxAppliedTorque
#
#		state.angular_velocity += tempVelocity
#
#	elif(current_velocity > angularVToAim):
#
#		var tempDamp = current_velocity - angularVToAim
#
#		if tempDamp > maxAppliedDamp:
#			tempDamp = maxAppliedDamp
#
#		state.angular_velocity -= tempDamp
	