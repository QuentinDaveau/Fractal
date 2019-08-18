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

var _body_parts_list: Array = [self]

var _pins_list: Dictionary = {}

var _scale_init_done = true







func setup(properties: Dictionary) -> void:
	position = properties.position
	.setup(properties)
	

func _ready():
	_body_parts_list = _get_all_nodes($BodyParts, _body_parts_list)
	_set_body_parts_layers(_body_parts_list)
	_set_collision_exception(_body_parts_list)


func _integrate_forces(state):
	_keep_body_straight(state)


func get_property(property_name):
	if not $Properties.get(property_name) == null:
		return $Properties.get(property_name)
	else:
		print("Uknown given property !")
		get_tree().quit()


func get_body_parts() -> Array:
	return _body_parts_list


func clear_exception_with(body: RigidBody2D):
	remove_collision_exception_with(body)


func _get_all_nodes(node:Node, array:Array) -> Array:
	for N in node.get_children():
		if N.is_class("RigidBody2D"):
			if N.get_child_count() > 0:
				array.append(N)
				array = _get_all_nodes(N, array)
			else:
				array.append(N)
	return array


func _set_collision_exception(array:Array) -> void:
	
	for element in array:
		for other_element in array:
			if(other_element != element):
				element.add_collision_exception_with(other_element)


func _set_body_parts_layers(array: Array) -> void:
	
	for element in array:
		if element is BodyPart:
			element.update_layers_and_masks(_layer_array, _mask_array)


func _define_layers() -> void:
	._define_layers()


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