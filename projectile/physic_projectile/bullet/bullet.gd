extends PhysicProjectile

var POWER: float = 10.0


func _ready():
	connect("body_entered", self, "_body_entered")


func _integrate_forces(state):
	
	var targetAngle = state.linear_velocity.angle()
	var selfAngle = rotation
	
	var current_velocity = state.angular_velocity
	
	var diffAngle = 0.0
	
	if(abs(targetAngle - selfAngle) > PI):
		var angSign = sign(targetAngle - selfAngle)
		diffAngle = (-PI*angSign)+((targetAngle - selfAngle)+(-PI*angSign))
	else:
		diffAngle = targetAngle - selfAngle
	
	var angularVToAim = sign(diffAngle) * ease(inverse_lerp(0, 3.14, abs(diffAngle)), 0.2) * POWER
	
	if(current_velocity < angularVToAim):
		state.angular_velocity += angularVToAim - current_velocity
	
	elif(current_velocity > angularVToAim):
		state.angular_velocity -= current_velocity - angularVToAim

func _body_entered(body: PhysicsBody2D) -> void:
	if body is Damageable:
		body.receive_damage(DAMAGE)
	_die()


func _die() -> void:
	._die()
	queue_free()