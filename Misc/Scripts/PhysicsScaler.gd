class_name PhysicsScaler extends RigidBody2D

var _scale_coeff: float = 1.0
var _layer_array: Array
var _mask_array: Array
var LAYERS_LENGTH: int = 32

func setup(properties: Dictionary) -> void:
	_scale_coeff = properties.scale_coeff
	_layer_array = properties.layer_array
	_mask_array = properties.mask_array

func _ready():
	_scale_self()
	_define_layers()

func update_layers_and_masks(layer_array: Array = [], mask_array: Array = []) -> void:
	if layer_array:
		_layer_array = layer_array
	if mask_array:
		_mask_array = mask_array
	_define_layers()

func update_scale_coeff(scale_coeff: float) -> void:
	if scale_coeff > 0:
		_scale_coeff = scale_coeff
	_scale_self()

func _scale_vector(unscaled_vector) -> void:
	unscaled_vector *= _scale_coeff

func _scale_mass(unscaled_mass: float) -> void:
	unscaled_mass = pow(unscaled_mass, _scale_coeff)

func _scale_speed(unscaled_speed: float) -> void:
	unscaled_speed /= pow(_scale_coeff, 2)

func _scale_self() -> void:
	pass

func _define_layers() -> void:
	for i in range(LAYERS_LENGTH):
		if _layer_array.has(i):
			set_collision_layer_bit(i, true)
		else:
			set_collision_layer_bit(i, false)
	
	for i in range(LAYERS_LENGTH):
		if _mask_array.has(i):
			set_collision_mask_bit(i, true)
		else:
			set_collision_mask_bit(i, false)
	
