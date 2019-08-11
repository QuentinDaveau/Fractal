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

var _pins_list: Dictionary = {}

var _scale_init_done = true







func setup(properties: Dictionary) -> void:
	.setup(properties)
	

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
			element.update_layers_and_masks(_layer_array, _mask_array)


func _custom_scale_self() -> void:
	
#	raycast.cast_to.y *= body_scale_mult * scale_coeff
	animationManager.set_play_speed(_scale_coeff)
	
	$BodyParts/ArmTop/ArmBottom/HandPin.position *= _scale_coeff
	$BodyParts/ArmTop2/ArmBottom2/HandPin2.position *= _scale_coeff
	
	$GrabArea/CollisionShape2D.get_shape().set_extents($GrabArea/CollisionShape2D.get_shape().get_extents() * _scale_coeff)
	
#	movement_acceleration /= pow(scale_coeff * body_mass_mult, 2)
#	_motion_dampening /= pow(scale_coeff * body_mass_mult, 2)
	
	print(movement_acceleration)
	
	_disable_pins()
	
	$Pins.position *= _scale_coeff

	for pin in $Pins.get_children():

		pin.position *= _scale_coeff
	
	for body_part in _body_parts_list:
		
		body_part.enabled = false
		
		var body_part_collision_shape = body_part.get_node("./CollisionShape2D").get_shape()
		
		if body_part_collision_shape is CapsuleShape2D:
			body_part_collision_shape.set_height(body_part_collision_shape.get_height() * _scale_coeff)
			body_part_collision_shape.set_radius(body_part_collision_shape.get_radius() * _scale_coeff)

		if body_part_collision_shape is CircleShape2D:
			body_part_collision_shape.set_radius(body_part_collision_shape.get_radius() * _scale_coeff)
			
		body_part.get_node("./CollisionShape2D").position *= _scale_coeff
		
		body_part.get_node("Sprite").scale *= _scale_coeff
		body_part.get_node("Sprite").position *= _scale_coeff
		
		body_part.mass *= _scale_coeff
		body_part.power /= _scale_coeff * _scale_coeff
		body_part.brakePower /= _scale_coeff * _scale_coeff
		body_part.maxAppliableAngularV /= _scale_coeff * _scale_coeff
		
		if body_part != self:
			body_part.position *= _scale_coeff
		
		body_part.gravity_scale = 0


func _define_layers() -> void:
	._define_layers()


func _disable_pins() -> void:
	
	for pin in $Pins.get_children():
		
		_pins_list[pin.get_name()] = [pin.get_node_a(), pin.get_node_b()]
		pin.set_node_a("")
		pin.set_node_b("")


func _enable_pins() -> void:
	
	for pin in $Pins.get_children():
		
		pin.set_node_a(_pins_list[pin.get_name()][0])
		pin.set_node_b(_pins_list[pin.get_name()][1])

func _integrate_forces(state):
	#	if !_scale_init_done:
#		_enable_pins()
#		for body_part in _body_parts_list:
#			body_part.gravity_scale = _starting_gravity_scale / (_scale_coeff * _scale_coeff * _scale_coeff)
##			body_part.gravity_scale = 1.0
#			body_part.enabled = true
#		_scale_init_done = true
	pass






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