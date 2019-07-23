class_name PhysicsScaler extends RigidBody2D

export(float) var scale_coeff: float = 1.0

export(float) var speed_coeff: float = 1.0
export(float) var body_scale_mult: float = 1.0
export(float) var body_mass_mult: float = 1.0

export(Array) var layer_array: Array
export(Array) var mask_array: Array

var _layers_length: int = 32

func init_physics_scaler(spawn_scale_coeff: float, spawn_speed_coeff: float, spawn_body_scale_mult: float, spawn_body_mass_mult: float, spawn_layer_array: Array, spawn_mask_array: Array) -> void:
	
	scale_coeff = spawn_scale_coeff
	speed_coeff = spawn_speed_coeff
	body_scale_mult = spawn_body_scale_mult
	body_mass_mult = spawn_body_mass_mult
	layer_array = spawn_layer_array
	mask_array = spawn_mask_array

func _ready():
	
	_scale_self()
	_define_layers()


func _scale_self() -> void:
	pass


func _define_layers() -> void:
	
	for i in range(_layers_length):
		if layer_array.has(i):
			set_collision_layer_bit(i, true)
		else:
			set_collision_layer_bit(i, false)
	
	for i in range(_layers_length):
		if mask_array.has(i):
			set_collision_mask_bit(i, true)
		else:
			set_collision_mask_bit(i, false)
	
