extends Damageable
class_name Character

#onready var raycast = $RayCast2D
onready var animationManager = $AnimationManager

export(bool) var enabled: bool = true

export(NodePath) var targetNodePath
onready var targetNode = get_node(targetNodePath)

export(float) var power = 3
export(float) var maxAppliedTorque = 100
export(float) var maxAppliedDamp = 100
export(float) var brakePower = 5
#export(float) var bodyPower = 1
export(float) var maxAppliableAngularV = 50

export(bool) var is_scaled: bool = false

export(float) var movement_acceleration: float = 20000.0

onready var _body_parts_list: Array = [self]
onready var _starting_gravity_scale = gravity_scale

var drawList = []

var jumping: bool = true
var jumping_held:bool = false

var jumping_strength: float
var jumping_held_strength: float

var _pins_list: Dictionary = {}

var _scale_init_done = true


signal device_set(device_id)

var _motion_acceleration: float
var _max_velocity: float

var _desired_direction = Vector2(0.0, 0.0)

var _jump_velocity: float
var _jump: bool = false

func _ready():
	
	_body_parts_list = _get_all_nodes($BodyParts, _body_parts_list)
	
	_set_body_parts_layers(_body_parts_list)
	
	_set_collision_exception(_body_parts_list)
#	$RayCast2D.add_collision_exception(_body_parts_list)
	$GroundedCheckers/GroundedCheckOnGround.add_collision_exception(_body_parts_list)
	$GroundedCheckers/GroundedCheckInAir.add_collision_exception(_body_parts_list)
	
	if is_scaled:
		_scale_init_done = false
		_custom_scale_self()
	
	emit_signal("device_set", get_property("DEVICE_ID"))

func update_velocity_limitations(max_velocity: float, acceleration: float):
	_motion_acceleration = acceleration
	_max_velocity = max_velocity

func set_velocity(direction: Vector2):
	_desired_direction = direction

func get_property(property_name):
	
	if not $CharacterProperties.get(property_name) == null:
		return $CharacterProperties.get(property_name)
	else:
		print("Uknown given property !")
		get_tree().quit()

func _get_all_nodes(node:Node, array:Array) -> Array:
	for N in node.get_children():
		if N.is_class("RigidBody2D"):
			if N.get_child_count() > 0:
				array.append(N)
				array = _get_all_nodes(N, array)
			else:
				array.append(N)
	return array


func get_body_parts() -> Array:
	return _body_parts_list


func clear_exception_with(body: RigidBody2D):
	remove_collision_exception_with(body)


func _set_collision_exception(array:Array) -> void:
	
	for element in array:
		for other_element in array:
			if(other_element != element):
				element.add_collision_exception_with(other_element)


func _set_body_parts_layers(array: Array) -> void:
	
	for element in array:
		if element is BodyPart:
			element.layer_array = layer_array
			element.mask_array = mask_array
			element.recalculate_layers()


func _custom_scale_self() -> void:
	
#	raycast.cast_to.y *= body_scale_mult * scale_coeff
	animationManager.set_play_speed(speed_coeff * scale_coeff)
	
	$BodyParts/ArmTop/ArmBottom/HandPin.position *= body_scale_mult * scale_coeff
	$BodyParts/ArmTop2/ArmBottom2/HandPin2.position *= body_scale_mult * scale_coeff
	
	$GrabArea/CollisionShape2D.get_shape().set_extents($GrabArea/CollisionShape2D.get_shape().get_extents() * body_scale_mult * scale_coeff)
	
#	movement_acceleration /= pow(scale_coeff * body_mass_mult, 2)
#	_motion_dampening /= pow(scale_coeff * body_mass_mult, 2)
	
	print(movement_acceleration)
	
	_disable_pins()
	
	$Pins.position *= body_scale_mult * scale_coeff

	for pin in $Pins.get_children():

		pin.position *= body_scale_mult * scale_coeff
	
	for body_part in _body_parts_list:
		
		body_part.enabled = false
		
		var body_part_collision_shape = body_part.get_node("./CollisionShape2D").get_shape()
		
		if body_part_collision_shape is CapsuleShape2D:
			body_part_collision_shape.set_height(body_part_collision_shape.get_height() * body_scale_mult * scale_coeff)
			body_part_collision_shape.set_radius(body_part_collision_shape.get_radius() * body_scale_mult * scale_coeff)

		if body_part_collision_shape is CircleShape2D:
			body_part_collision_shape.set_radius(body_part_collision_shape.get_radius() * body_scale_mult * scale_coeff)
			
		body_part.get_node("./CollisionShape2D").position *= body_scale_mult * scale_coeff
		
		body_part.get_node("Sprite").scale *= body_scale_mult * scale_coeff
		body_part.get_node("Sprite").position *= body_scale_mult * scale_coeff
		
		body_part.mass *= body_mass_mult * scale_coeff
		body_part.power /= body_mass_mult * scale_coeff * speed_coeff
		body_part.brakePower /= body_mass_mult * scale_coeff * speed_coeff
		body_part.maxAppliableAngularV /= body_mass_mult * scale_coeff * speed_coeff
		
		if body_part != self:
			body_part.position *= body_scale_mult * scale_coeff
		
		body_part.gravity_scale = 0


func _define_layers() -> void:
	
	._define_layers()
	for i in range(_layers_length):
		if mask_array.has(i):
#			$RayCast2D.set_collision_mask_bit(i, true)
			$GroundedCheckers/GroundedCheckOnGround.set_collision_mask_bit(i, true)
			$GroundedCheckers/GroundedCheckInAir.set_collision_mask_bit(i, true)
		else:
#			$RayCast2D.set_collision_mask_bit(i, false)
			$GroundedCheckers/GroundedCheckOnGround.set_collision_mask_bit(i, true)
			$GroundedCheckers/GroundedCheckInAir.set_collision_mask_bit(i, true)


func _disable_pins() -> void:
	
	for pin in $Pins.get_children():
		
		_pins_list[pin.get_name()] = [pin.get_node_a(), pin.get_node_b()]
		pin.set_node_a("")
		pin.set_node_b("")


func _enable_pins() -> void:
	
	for pin in $Pins.get_children():
		
		pin.set_node_a(_pins_list[pin.get_name()][0])
		pin.set_node_b(_pins_list[pin.get_name()][1])


func jump(velocity: float) -> void:
	_jump_velocity = velocity
	_jump = true

func update_jump_gravity(gravity_multiplier: float) -> void:
	gravity_scale = gravity_multiplier


func release_jump() -> void:
	jumping_held = false


func _integrate_forces(state):
	
	if !_scale_init_done:
		_enable_pins()
		for body_part in _body_parts_list:
			body_part.gravity_scale = _starting_gravity_scale / (speed_coeff * scale_coeff * scale_coeff)
#			body_part.gravity_scale = 1.0
			body_part.enabled = true
		_scale_init_done = true
	
	if !enabled:
		return
	
#	applied_force.x = 0.0
#
#	add_central_force(Vector2(forceVector.x, 0.0))

#	state.linear_velocity.x = forceVector.x
#	_move_player(state)
	_move_player_forces(state)
	
	if _jump:
#		apply_central_impulse(Vector2(0.0,jumping_strength - (linear_velocity.y * 7)))
		state.linear_velocity.y = -_jump_velocity
		_jump = false
	
	
#	if jumping_held:
#		applied_force.y = jumping_held_strength
#	else:
#		applied_force.y = 0
	
#	$RayCast2D.global_rotation = 0.0
	$GroundedCheckers/GroundedCheckOnGround.global_rotation = 0.0
	$GroundedCheckers/GroundedCheckInAir.global_rotation = 0.0
	
#	state.linear_velocity.x = 200
#	if raycast.is_colliding():
#		gravity_scale = 1
	
	_keep_body_straight(state)


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
#	if abs(current_velocity) > _motion_dampening:
#		current_velocity -= _motion_dampening * sign(state.linear_velocity.x)
#	else:
#		current_velocity = 0.0
#
#	state.linear_velocity.x = current_velocity


func _move_player_forces(state: Physics2DDirectBodyState) -> void:
	
	applied_force.x = 0.0
	
	var current_velocity = linear_velocity.x
	var desired_velocity = _desired_direction.x * _max_velocity
	
	if abs(current_velocity) < abs(desired_velocity):
		add_central_force(Vector2(ease(inverse_lerp(0, desired_velocity, desired_velocity - current_velocity), 0.1) * _motion_acceleration * sign(desired_velocity), .0))
	
	if abs(current_velocity) > _max_velocity:
		add_central_force(Vector2(ease(inverse_lerp(desired_velocity, desired_velocity + (_motion_acceleration/mass), abs(current_velocity)), 0.1) * -_motion_acceleration * sign(current_velocity), .0))

func _keep_body_straight(state: Physics2DDirectBodyState) -> void:
	
	var targetAngle = targetNode.rotation
	var selfAngle = global_rotation
	var current_velocity = state.angular_velocity
	var diffAngle = 0

	if(abs(targetAngle - selfAngle) > PI):
		var angSign = sign(targetAngle - selfAngle)
		diffAngle = (-PI*angSign)+((targetAngle - selfAngle)+(-PI*angSign))
	else:
		diffAngle = targetAngle - selfAngle
	
	var angularVToAim = sign(diffAngle) * ease(inverse_lerp(0, 3.14, abs(diffAngle)), 0.1) * power
	
	if(sign(angularVToAim) != sign(angular_velocity)):
		angularVToAim += brakePower * (abs(abs(angularVToAim) - abs(angular_velocity))) * sign(angularVToAim)
	
	if(abs(angularVToAim) > maxAppliableAngularV):
		angularVToAim = maxAppliableAngularV * sign(angularVToAim)
	
#	print("Différence angle: ",diffAngle,", Torque désiré: ",angularVToAim,", Torque réel: ",applied_torque)
	
	if(current_velocity < angularVToAim):
		
		var tempVelocity = angularVToAim - current_velocity
	
		if tempVelocity > maxAppliedTorque:
			tempVelocity = maxAppliedTorque
	
		state.angular_velocity += tempVelocity
	
	elif(current_velocity > angularVToAim):
	
		var tempDamp = current_velocity - angularVToAim
	
		if tempDamp > maxAppliedDamp:
			tempDamp = maxAppliedDamp
	
		state.angular_velocity -= tempDamp
	