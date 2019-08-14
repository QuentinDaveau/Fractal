class_name Firearm extends Weapon

onready var _barrels_array: Array = _get_all_barrels()


func _scale_self() -> void:
	for barrel in _get_all_barrels():
		barrel.position  = _scale_vector(barrel.position)
		barrel.SCALE_COEFF = _scale_coeff
		barrel.LAYERS = {"layer":_layer_array, "mask":_mask_array}
	._scale_self()


func _attack() -> void:
	for barrel in _barrels_array:
		barrel.fire_from_barrel()


func _get_all_barrels() -> Array:
	var temp_barrel_aray = Array()
	
	for node in get_children():
		if node is ProjectileSpawner:
			temp_barrel_aray.append(node)
	return temp_barrel_aray