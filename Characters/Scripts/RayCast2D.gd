extends RayCast2D

var collides:bool = false

signal collision_entered
signal collision_exited

func _ready():
	pass 

func add_collision_exception(bodies_array: Array) -> void:
	for body in bodies_array:
		add_exception(body)

func _physics_process(delta):
	if is_colliding() && !collides:
		emit_signal("collision_entered")
		collides = true
	elif !is_colliding() && collides:
		emit_signal("collision_exited")
		collides = false