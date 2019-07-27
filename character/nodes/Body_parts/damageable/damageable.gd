extends PhysicsScaler
class_name Damageable

signal damage_received(amount)
signal died()

export(float) var health_amount: float setget set_health
export(float) var damage_multiplier: float = 1.0

var _left_health: float = health_amount


func set_health(amount: float):
	
	if amount < 0:
		amount = 0
	health_amount = amount
	
	if _left_health > health_amount:
		_left_health = health_amount


func _die():
	emit_signal("died")
	pass


func receive_damage(amount: float):
	
	var health_lost = amount * damage_multiplier
	_left_health -= health_lost
	
	if _left_health > 0:
		emit_signal("damage_received", health_lost, _left_health)
	else:
		_die()
	