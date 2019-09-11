extends Spawnable
class_name PhysicsScaler

"""
Offers basic functions to scale objects and set their collision layer and mask
"""

const LAYERS_LENGTH: int = 32

var _scale_coeff: float = 1.0
var _layer_array: Array
var _mask_array: Array


func setup(properties: Dictionary) -> void:
	_scale_coeff = properties.scale_coeff
	_layer_array = properties.layer_array
	_mask_array = properties.mask_array
	.setup(properties)


func _ready():
	_scale_self()
	_define_layers()


func get_scale_coeff() -> float:
	return _scale_coeff


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


func _scale_self() -> void:
	pass


func _scale_vector(unscaled_vector):
	return unscaled_vector * _scale_coeff


func _scale_mass(unscaled_mass: float) -> float:
	return unscaled_mass * pow(_scale_coeff, 3)


func _scale_speed(unscaled_speed: float) -> float:
	return unscaled_speed / pow(_scale_coeff, 2)


func _scale_power(unscaled_power: float) -> float:
	return unscaled_power / _scale_coeff


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
	
