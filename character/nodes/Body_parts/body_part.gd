extends Damageable
class_name BodyPart

export(NodePath) var targetNodePath
onready var targetNode = get_node(targetNodePath)

export(bool) var enabled: bool = true

export(float) var POWER = 20
export(float) var MAX_APPLIED_AVELOCITY = 100
export(float) var MAX_APPLIED_DAMPENING = 100
export(float) var BRAKE_POWER = 1

export(bool) var ANGLE_RESTRICTION = false
export(float) var MIN_ANGLE = -0
export(float) var MAX_ANGLE = -0
export(float) var RESTRICTION_POWER = 5

export(int) var MAX_AVELOCITY_VARIATION = 15


func _scale_self() -> void:
	var collision_shape = get_node("./CollisionShape2D").get_shape()
	if collision_shape is CapsuleShape2D:
		collision_shape.set_height(_scale_vector(collision_shape.get_height()))
		collision_shape.set_radius(_scale_vector(collision_shape.get_radius()))
	elif collision_shape is CircleShape2D:
		collision_shape.set_radius(_scale_vector(collision_shape.get_radius()))

	get_node("./CollisionShape2D").position = _scale_vector(get_node("./CollisionShape2D").position)
	get_node("Sprite").scale = _scale_vector(get_node("Sprite").scale)
	get_node("Sprite").position = _scale_vector(get_node("Sprite").position)

	position = _scale_vector(position)
	mass = _scale_mass(mass)
	POWER = _scale_speed(POWER)
	BRAKE_POWER = _scale_speed(BRAKE_POWER)
	MAX_AVELOCITY_VARIATION = _scale_speed(MAX_AVELOCITY_VARIATION)
	gravity_scale = _scale_speed(gravity_scale)


func _integrate_forces(state):
	
	if !enabled:
		return
	
	var targetAngle = targetNode.rotation
	var selfAngle = rotation
	
	var current_velocity = state.angular_velocity
	var temp_power = POWER
	
	if(ANGLE_RESTRICTION):
		if(MIN_ANGLE < MAX_ANGLE):
			if(selfAngle < MIN_ANGLE):
				temp_power += RESTRICTION_POWER * abs(abs(MIN_ANGLE) - abs(selfAngle))
			elif(selfAngle > MAX_ANGLE):
				temp_power += RESTRICTION_POWER * abs(abs(MIN_ANGLE) - abs(selfAngle))
		else:
			if(selfAngle < MIN_ANGLE && selfAngle > MAX_ANGLE):
				temp_power += RESTRICTION_POWER * abs(abs(MIN_ANGLE) - abs(selfAngle))
	
	var diffAngle = 0
	
	if(abs(targetAngle - selfAngle) > PI):
		var angSign = sign(targetAngle - selfAngle)
		diffAngle = (-PI*angSign)+((targetAngle - selfAngle)+(-PI*angSign))
	else:
		diffAngle = targetAngle - selfAngle
	
	var angularVToAim = sign(diffAngle) * ease(inverse_lerp(0, 3.14, abs(diffAngle)), 0.2) * temp_power
	
	if(sign(angularVToAim) != sign(angular_velocity)):
		angularVToAim += BRAKE_POWER * (abs(abs(angularVToAim) - abs(angular_velocity))) * sign(angularVToAim)
	
	if(abs(angularVToAim) > MAX_AVELOCITY_VARIATION):
		angularVToAim = MAX_AVELOCITY_VARIATION * sign(angularVToAim)
	
	
	if(current_velocity < angularVToAim):
		
		var tempVelocity = angularVToAim - current_velocity
	
		if tempVelocity > MAX_APPLIED_AVELOCITY:
			tempVelocity = MAX_APPLIED_AVELOCITY
	
		state.angular_velocity += tempVelocity
	
	elif(current_velocity > angularVToAim):
	
		var tempDamp = current_velocity - angularVToAim
	
		if tempDamp > MAX_APPLIED_DAMPENING:
			tempDamp = MAX_APPLIED_DAMPENING
	
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