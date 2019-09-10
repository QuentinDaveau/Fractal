extends PhysicProjectile


func _ready():
	connect("body_entered", self, "_body_entered")


func _body_entered(body: PhysicsBody2D) -> void:
	if body is Damageable:
		body.receive_damage(DAMAGE)
	_die()


func _die() -> void:
	._die()
	queue_free()