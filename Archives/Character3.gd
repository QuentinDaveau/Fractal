extends PhysicsScaler
class_name Character3

onready var raycast = $RayCast2D

export(bool) var enabled: bool = true

export(NodePath) var targetNodePath
onready var targetNode = get_node(targetNodePath)

export(float) var power = 20
export(float) var maxAppliedTorque = 100
export(float) var maxAppliedDamp = 100
export(float) var brakePower = 5
#export(float) var bodyPower = 1
export(float) var maxAppliableAngularV = 50

export(bool) var is_scaled: bool = false
export(int) var repulse_force: int = 25

onready var _body_parts_list: Array = [self]
var drawList = []

var forceVector = Vector2(0.0, 0.0)

var jumping: bool = true
var jumping_held:bool = false

var jumping_strength: float
var jumping_held_strength: float

var _pins_list: Dictionary = {}

var _scale_init_done = true
onready var _starting_gravity_scale = gravity_scale

func _ready():
	
	_body_parts_list = _get_all_nodes($BodyParts, _body_parts_list)
	
	_set_body_parts_layers(_body_parts_list)
	
	_set_collision_exception(_body_parts_list)
	$RayCast2D.add_collision_exception(_body_parts_list)
	
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

func set_replay(actions_log: Array) -> void:
	if get_node("ActionPlayer") != null:
		$ActionPlayer.actions_log = actions_log

func get_replay() -> Array:
	if get_node("ActionLogger") != null:
		return [$ActionLogger.get_start_position(), $ActionLogger.get_log()]
	else:
		return []

func get_body_parts() -> Array:
	return _body_parts_list

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
	
	$RayCast2D.cast_to.y *= body_scale_mult * scale_coeff
	$AnimationTree["parameters/TimeScale/scale"] /= speed_coeff * scale_coeff
	repulse_force /= body_mass_mult * scale_coeff
	
	$BodyParts/ArmTop/ArmBottom/HandPin.position *= body_scale_mult * scale_coeff
	$BodyParts/ArmTop2/ArmBottom2/HandPin2.position *= body_scale_mult * scale_coeff
	
	$GrabArea/CollisionShape2D.get_shape().set_extents($GrabArea/CollisionShape2D.get_shape().get_extents() * body_scale_mult * scale_coeff)
	
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
		
		body_part.mass *= body_mass_mult * scale_coeff * scale_coeff
		
		if body_part != self:
			body_part.position *= body_scale_mult * scale_coeff
		
		body_part.gravity_scale = 0
	

func _define_layers() -> void:
	
	._define_layers()
	for i in range(_layers_length):
		if mask_array.has(i):
			$RayCast2D.set_collision_mask_bit(i, true)
		else:
			$RayCast2D.set_collision_mask_bit(i, false)

func _disable_pins() -> void:
	
	for pin in $Pins.get_children():
		
		_pins_list[pin.get_name()] = [pin.get_node_a(), pin.get_node_b()]
		pin.set_node_a("")
		pin.set_node_b("")
	

func _enable_pins() -> void:
	
	for pin in $Pins.get_children():
		
		pin.set_node_a(_pins_list[pin.get_name()][0])
		pin.set_node_b(_pins_list[pin.get_name()][1])

func jump(strength: float, held_strength: float) -> void:
	jumping_strength = strength
	jumping_held_strength = held_strength
	jumping = true
	jumping_held = true

func release_jump() -> void:
	jumping_held = false


func _integrate_forces(state):
	
	if !_scale_init_done:
		_enable_pins()
		for body_part in _body_parts_list:
			body_part.gravity_scale = _starting_gravity_scale / (speed_coeff * scale_coeff * scale_coeff)
			body_part.enabled = true
		_scale_init_done = true
	
	if !enabled:
		return
	
	state.linear_velocity.x = forceVector.x
	
	if jumping:
#		print(jumping_strength - (0.5 * pow(linear_velocity.y, 2) * 64))
		apply_central_impulse(Vector2(0.0,jumping_strength - (linear_velocity.y * 7)))
		jumping = false
	
#	print(linear_velocity.y)
	
	if jumping_held:
		applied_force.y = jumping_held_strength
	else:
		applied_force.y = 0


	$RayCast2D.global_rotation = 0.0

#	state.linear_velocity.x = 200

	if(raycast.is_colliding() && state.linear_velocity.y > 0):

		state.linear_velocity.y = -repulse_force

#		print(applied_force)

	var targetAngle = 0.0
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
	
	state.integrate_forces()

func _impulse_to_reach(body, anchor):
	
	
	body.add_force(anchor.position, -anchor.appliedForce)
	
	var appliedForce = (anchor.target.global_position - anchor.global_position) * (anchor.target.global_position - anchor.global_position).abs() * power
	anchor.appliedForce = appliedForce

	drawList.append([anchor.position, anchor.position + appliedForce])
#	print(anchor.appliedForce)
#	print(anchor.position)
	body.add_force(anchor.position, appliedForce)

func _draw():
	
	for element in drawList:
	
		draw_line(element[0], element[1], Color(255, 0, 0))