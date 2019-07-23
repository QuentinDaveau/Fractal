class_name Gun extends Weapon

onready var _barrels_array: Array = _get_all_barrels()


func _ready():
	for barrel in _barrels_array:
		barrel.position *= scale_coeff * body_scale_mult
		_set_barrel_scale_coeff(barrel)
		_set_barrel_layers(barrel)


func attack() -> void:
	print("attack2")
	for barrel in _barrels_array:
		barrel.fire_from_barrel()


func _get_all_barrels() -> Array:
	
	var temp_barrel_aray = Array()
	
	for node in get_children():
		if node is BarrelExit:
			temp_barrel_aray.append(node)
	
	return temp_barrel_aray


func _set_barrel_scale_coeff(barrel: BarrelExit) -> void:
	
	barrel.projectile_scale_coeff = scale_coeff
	barrel.projectile_speed_mult = speed_coeff
	barrel.projectile_scale_mult = body_scale_mult
	barrel.projectile_mass_mult = body_mass_mult

func _set_barrel_layers(barrel: BarrelExit) -> void:
	
	barrel.projectile_layer_array = layer_array
	barrel.projectile_mask_array = mask_array
	