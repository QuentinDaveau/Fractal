extends Character
class_name Player


var _motion_acceleration: float
var _max_velocity: float
var _desired_direction = Vector2(0.0, 0.0)
var _jump_velocity: float
var _jump: bool = false


func setup(properties: Dictionary) -> void:
	$Properties.DEVICE_ID = properties.device_id
	.setup(properties)


func _integrate_forces(state):
	if !enabled:
		return
	
	$GroundedCheckers/GroundedCheckOnGround.global_rotation = 0.0
	$GroundedCheckers/GroundedCheckInAir.global_rotation = 0.0
	if _jump:
		state.linear_velocity.y = -_jump_velocity
		_jump = false
	_move_player(state)
	._integrate_forces(state)


func get_replay() -> Dictionary:
	return {"start_position": $ActionLogger.get_start_position(), "logs": $ActionLogger.get_log(), "id": get_id()}


func update_velocity_limitations(max_velocity: float, acceleration: float) -> void:
	_motion_acceleration = acceleration
	_max_velocity = max_velocity


func set_velocity(direction: Vector2) -> void:
	_desired_direction = direction


func jump(velocity: float) -> void:
	_jump_velocity = velocity
	_jump = true


func update_jump_gravity(gravity_multiplier: float) -> void:
	gravity_scale = gravity_multiplier


func _define_layers() -> void:
	
	for i in range(LAYERS_LENGTH):
		if _layer_array.has(i):
			$BodyParts/ArmTop/ArmBottom/RightPickArea.set_collision_layer_bit(i, true)
			$BodyParts/ArmTop2/ArmBottom2/LeftPickArea.set_collision_layer_bit(i, true)
			$BodyParts/ArmTop/ArmBottom/RightGrabArea.set_collision_layer_bit(i, true)
			$BodyParts/ArmTop2/ArmBottom2/LeftGrabArea.set_collision_layer_bit(i, true)
		else:
			$BodyParts/ArmTop/ArmBottom/RightPickArea.set_collision_layer_bit(i, false)
			$BodyParts/ArmTop2/ArmBottom2/LeftPickArea.set_collision_layer_bit(i, false)
			$BodyParts/ArmTop/ArmBottom/RightGrabArea.set_collision_layer_bit(i, false)
			$BodyParts/ArmTop2/ArmBottom2/LeftGrabArea.set_collision_layer_bit(i, false)
	
	for i in range(LAYERS_LENGTH):
		if _mask_array.has(i):
			$GroundedCheckers/GroundedCheckOnGround.set_collision_mask_bit(i, true)
			$GroundedCheckers/GroundedCheckInAir.set_collision_mask_bit(i, true)
			$BodyParts/ArmTop/ArmBottom/RightGrabArea.set_collision_mask_bit(i, true)
			$BodyParts/ArmTop2/ArmBottom2/LeftGrabArea.set_collision_mask_bit(i, true)
		else:
			$GroundedCheckers/GroundedCheckOnGround.set_collision_mask_bit(i, false)
			$GroundedCheckers/GroundedCheckInAir.set_collision_mask_bit(i, false)
			$BodyParts/ArmTop/ArmBottom/RightGrabArea.set_collision_layer_bit(i, false)
			$BodyParts/ArmTop2/ArmBottom2/LeftGrabArea.set_collision_layer_bit(i, false)
	._define_layers()


func _move_player(state: Physics2DDirectBodyState) -> void:
	
	applied_force.x = 0.0
	
	var current_velocity = linear_velocity.x
	var desired_velocity = _desired_direction.x * _max_velocity
	
	if abs(current_velocity) < abs(desired_velocity):
		add_central_force(Vector2(ease(inverse_lerp(0, desired_velocity, desired_velocity - current_velocity), 0.1) * _motion_acceleration * sign(desired_velocity), .0))
	if abs(current_velocity) > _max_velocity:
		add_central_force(Vector2(ease(inverse_lerp(desired_velocity, desired_velocity + (_motion_acceleration/mass), abs(current_velocity)), 0.1) * -_motion_acceleration * sign(current_velocity), .0))

