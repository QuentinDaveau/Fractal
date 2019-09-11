extends Barrel


func _enable() -> void:
	_shoot_projectile()


func _shoot_projectile() -> void:
	for spawner in spawners:
		spawner.spawn()
	_start_cooldown()
	._shoot_projectile()


func _on_cooldown_timeout() -> void:
	state = STATES.IDLE
