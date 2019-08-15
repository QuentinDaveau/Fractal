extends Position2D
class_name Barrel

enum STATES {IDLE, COOLDOWN, SHOOTING}

export(float) var cooldown: float
export(Vector2) var knockback: = Vector2.ZERO


var SCALE_COEFF: float = 1.0
var LAYERS: Dictionary = {}

var state = STATES.IDLE

onready var spawners: Array = _get_spawners()


func _ready():
	$CooldownTimer.connect("timeout", self, "_on_cooldown_timeout")
	$CooldownTimer.wait_time = cooldown


func fire() -> void:
	if state == STATES.SHOOTING or state == STATES.COOLDOWN:
		return
	_enable()


func release() -> void:
	if state == STATES.IDLE:
		return
	_disable()


func _enable() -> void:
	pass


func _disable() -> void:
	pass


func _start_cooldown() -> void:
	if cooldown > 0:
		$CooldownTimer.start(cooldown)
		state = STATES.COOLDOWN


func _shoot_projectile() -> void:
	_apply_knockback()


func _apply_knockback() -> void:
	var parent = get_parent()
	if parent is RigidBody2D:
		parent.apply_impulse(position, -knockback.rotated(global_rotation) / SCALE_COEFF)


func _on_cooldown_timeout():
	pass


func _get_spawners() -> Array:
	spawners = []
	for node in get_children():
		if node is ProjectileSpawner:
			spawners.append(node)
	return spawners