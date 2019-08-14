extends Position2D
class_name BarrelExit

enum BarrelTypeEnum {SINGLE_FIRE, AUTO_FIRE, BURST_FIRE, CHARGING}

export(PackedScene) var projectile_type: PackedScene setget set_projectile_type, get_projectile_type

export(float, 0, 10000) var projectile_velocity: float = 0.0
export(int, 0, 10) var projectile_count: int = 1

export(Vector2) var barrel_knockback: Vector2 = Vector2(0.0, 0.0)
export(float, 0, 60) var barrel_cooldown: float = 0.1
export(int, 0, 10) var barrel_burst_fire_count: int = 3
export(float, 0, 1) var barrel_burst_fire_speed: float = 0.5

export(BarrelTypeEnum) var barrel_type

var projectile_scale_coeff: float = 1.0

var projectile_speed_mult: float = 1.0
var projectile_scale_mult: float = 1.0
var projectile_mass_mult: float = 1.0

var projectile_layer_array: Array = []
var projectile_mask_array: Array = []


var SCALE_COEFF: float = 1.0

var _is_projectile_class: bool = false
var _is_shooting: bool = false
var _is_on_cooldown: bool = false


func _ready():
	$CooldownTimer.wait_time = barrel_cooldown
	$CooldownTimer.one_shot = true


func fire_from_barrel() -> void:
	if _is_on_cooldown:
		return
	
	match barrel_type:
		BarrelTypeEnum.SINGLE_FIRE:
			if _is_shooting:
				return
			else:
				_shoot_projectile()
				_start_barrel_cooldown()

func _start_barrel_cooldown() -> void:
	_is_on_cooldown = true
	$CooldownTimer.start()

func _shoot_projectile() -> void:
	var projectile_instance = projectile_type.instance()
#	projectile_instance.init(global_position, global_rotation, Vector2(1.0, 0.0).rotated(global_rotation) * projectile_velocity / (projectile_scale_coeff * projectile_speed_mult))
	_set_projectile_properties(projectile_instance)
	_apply_knockback()
	get_tree().get_root().add_child(projectile_instance)

func _apply_knockback() -> void:
	var parent = get_parent()
	if parent is RigidBody2D:
		parent.apply_impulse(position, barrel_knockback.rotated(global_rotation))

func _set_projectile_properties(projectile: RigidBody2D) -> void:
	
	if projectile is Projectile:
		projectile.global_position = global_position - (projectile.get_node("SpawnOrigin").position * projectile_scale_coeff * projectile_scale_mult)
	else:
		projectile.global_position = global_position
	
	projectile.global_rotation = global_rotation
	
	projectile.linear_velocity = Vector2(1.0, 0.0).rotated(global_rotation) * projectile_velocity / (projectile_scale_coeff * projectile_speed_mult)
	
	print(projectile.linear_velocity)
	
	_set_projectile_scales(projectile)

func _set_projectile_scales(projectile: Node):
	
	if projectile is PhysicsScaler:
		projectile.scale_coeff = projectile_scale_coeff
		projectile.speed_coeff = projectile_speed_mult
		projectile.body_scale_mult = projectile_scale_mult
		projectile.body_mass_mult = projectile_mass_mult
		
		projectile.layer_array = projectile_layer_array
		projectile.mask_array = projectile_mask_array

func set_projectile_type(value: PackedScene):
	if value.is_class("Projectile"):
		_is_projectile_class = true
		projectile_type = value
	else:
		_is_projectile_class = false
		projectile_type = value

func get_projectile_type():
	return projectile_type

func _on_Cooldown_timeout():
	_is_on_cooldown = false
