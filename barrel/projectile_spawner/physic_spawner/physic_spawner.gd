extends ProjectileSpawner

export(float) var VELOCITY

onready var parent = get_parent()

func spawn() -> void:
	var projectile_instance = PROJECTILE.instance()
	projectile_instance.setup({
		"global_position": parent.global_position, 
		"global_rotation": parent.global_rotation,
		"linear_velocity": VELOCITY,
		"scale_coeff": parent.SCALE_COEFF,
		"layer_array": parent.LAYERS.layer,
		"mask_array": parent.LAYERS.mask
		})
	get_tree().get_root().add_child(projectile_instance)
