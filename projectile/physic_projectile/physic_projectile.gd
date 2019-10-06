extends PhysicsScaler
class_name PhysicProjectile

export(PackedScene) var IMPACT_PARTICLE: PackedScene

const DAMAGE: float = 1.0
const OUT_OF_SPAWN_DELAY: float = 0.2

var OWNER: PhysicsBody2D


func setup(properties: Dictionary) -> void:
	.setup(properties)
	global_position = properties.global_position - (_scale_vector($SpawnOrigin.position)).rotated(properties.global_rotation)
	global_rotation = properties.global_rotation
	linear_velocity = Vector2(_scale_vector(_scale_speed(properties.linear_velocity)), 0).rotated(properties.global_rotation)
	OWNER = properties.owner
	add_collision_exception_with(OWNER)


func _ready() -> void:
	$OutOfSpawnDelay.connect("timeout", self, "_out_of_spawn_timeout")
	$OutOfSpawnDelay.start(OUT_OF_SPAWN_DELAY)


func _scale_self():
	mass = _scale_mass(mass)
	gravity_scale = _scale_speed(_scale_power(gravity_scale))
	
	var vertex_buffer: = []
	for vertex in $CollisionPolygon2D.polygon:
		vertex_buffer.append(_scale_vector(vertex))
	$CollisionPolygon2D.set_polygon(vertex_buffer)


func _out_of_spawn_timeout() -> void:
	remove_collision_exception_with(OWNER)


func _die() -> void:
	pass
