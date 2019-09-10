extends PhysicsScaler
class_name Damageable

signal damage_received(amount)
signal died()

export(float) var MAX_HEALTH: float setget set_health
export(float) var DAMAGE_MULTIPLIER: float = 1.0

var _health_left: float = MAX_HEALTH


func set_health(amount: float):
	
	if amount < 0:
		amount = 0
	MAX_HEALTH = amount
	
	if _health_left > MAX_HEALTH:
		_health_left = MAX_HEALTH


func _die():
	emit_signal("died")


func receive_damage(amount: float):
	
	var health_lost = amount * DAMAGE_MULTIPLIER
	_health_left -= health_lost
	
	if _health_left > 0:
		emit_signal("damage_received", health_lost, _health_left)
	else:
		_die()
	