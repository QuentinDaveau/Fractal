extends Damageable
class_name BodyPart

export(NodePath) var targetNodePath
export(NodePath) var REFERENCE_NODE_PATH
onready var targetNode = get_node(targetNodePath)
var _reference_node

export(bool) var enabled: bool = true

export(float) var power = 2
export(float) var maxAppliedAngularV = 100
export(float) var maxAppliedDamp = 100
export(float) var brakePower = 5

export(bool) var AngleRestriction = false
export(float) var minAngle = -0
export(float) var maxAngle = -0
export(float) var restrictionPower = 5

export(int) var maxAppliableAngularV = 10

func _ready():
	if REFERENCE_NODE_PATH:
		_reference_node = get_node(REFERENCE_NODE_PATH)

func recalculate_layers() -> void:
	_define_layers()


func _integrate_forces(state):
	
	if !enabled:
		return
	
	var targetAngle
	
	if not _reference_node:
	 	targetAngle = targetNode.rotation
	else:
		targetAngle = targetNode.rotation + _reference_node.rotation
	
	
	
	var selfAngle = rotation
	
	var current_velocity = state.angular_velocity
	var tempPower = power
	
	if(AngleRestriction):
		if(minAngle < maxAngle):
			if(selfAngle < minAngle):
				tempPower += restrictionPower * abs(abs(minAngle) - abs(selfAngle))
			elif(selfAngle > maxAngle):
				tempPower += restrictionPower * abs(abs(minAngle) - abs(selfAngle))
		else:
			if(selfAngle < minAngle && selfAngle > maxAngle):
				tempPower += restrictionPower * abs(abs(minAngle) - abs(selfAngle))
	
	var diffAngle = 0
	
	if(abs(targetAngle - selfAngle) > PI):
		var angSign = sign(targetAngle - selfAngle)
		diffAngle = (-PI*angSign)+((targetAngle - selfAngle)+(-PI*angSign))
	else:
		diffAngle = targetAngle - selfAngle
	
	var angularVToAim = sign(diffAngle) * ease(inverse_lerp(0, 3.14, abs(diffAngle)), 0.2) * tempPower
	
	if(sign(angularVToAim) != sign(angular_velocity)):
		angularVToAim += brakePower * (abs(abs(angularVToAim) - abs(angular_velocity))) * sign(angularVToAim)
	
	if(abs(angularVToAim) > maxAppliableAngularV):
		angularVToAim = maxAppliableAngularV * sign(angularVToAim)
	
	
	if(current_velocity < angularVToAim):
		
		var tempVelocity = angularVToAim - current_velocity
	
		if tempVelocity > maxAppliedAngularV:
			tempVelocity = maxAppliedAngularV
	
		state.angular_velocity += tempVelocity
	
	elif(current_velocity > angularVToAim):
	
		var tempDamp = current_velocity - angularVToAim
	
		if tempDamp > maxAppliedDamp:
			tempDamp = maxAppliedDamp
	
		state.angular_velocity -= tempDamp


func clear_exception_with(body: RigidBody2D):
	remove_collision_exception_with(body)


func become_inert(exceptions: Array = []):
	
	enabled = false
	
	yield(get_tree().create_timer(.5), "timeout")
	
	for body in get_collision_exceptions():
		if !exceptions.has(body):
			remove_collision_exception_with(body)
			body.clear_exception_with(self)
			
	print(get_collision_exceptions(), "   r")

func _die():
	
	var exceptions = []
	
	for child in get_children():
		print(child.get_name())
		if child is PinJoint2D:
			if child.get_node(child.node_a).get_instance_id() == get_instance_id():
				child.node_a = ""
			elif child.get_node(child.node_b).get_instance_id() == get_instance_id():
				child.node_b = ""
		
		if child is Damageable:
			child.become_inert([self])
			exceptions.append(child)
	
	become_inert(exceptions)
	
	._die()