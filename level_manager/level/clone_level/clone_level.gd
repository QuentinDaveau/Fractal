extends Level

export(PackedScene) var CLONE_SCENE: PackedScene

var CHARACTER_LOGS: Array = []
var LEVEL_LOGS: Array = []
var ZOOM_POSITION: Vector2
var LEVEL_SCALE: float = 1.0


func setup(properties: Dictionary) -> void:
	CHARACTER_LOGS = properties.characters_logs
	LEVEL_LOGS = properties.level_logs
	ZOOM_POSITION = properties.zoom_position
	LEVEL_SCALE = properties.scale
	scale *= LEVEL_SCALE
	position = ZOOM_POSITION - (ZOOM_POSITION * LEVEL_SCALE)
	.setup(properties)


func _ready():
	if CHARACTER_LOGS.size() > 0:
		for character_datas in CHARACTER_LOGS:
			_spawn_clone(character_datas)


func disassemble() -> Dictionary:
	queue_free()
	return {"logs": [LEVEL_LOGS, CHARACTER_LOGS], "gen": LEVEL_GEN, "map": MAP}


func get_logs() -> Array:
	return [LEVEL_LOGS, CHARACTER_LOGS]


func _spawn_clone(character_datas: Array) -> void:
	
	var clone_instance = CLONE_SCENE.instance()
	clone_instance.scale = Vector2.ONE / LEVEL_SCALE
	var layers_array = _get_character_layers()
	
	clone_instance.setup({
		"position": _get_scaled_position(character_datas[0]),
		"scale_coeff": LEVEL_SCALE,
		"layer_array": layers_array[0],
		"mask_array": layers_array[0],
		"replay": character_datas[1],
		"zoom_position": ZOOM_POSITION
		})
	
	add_child(clone_instance)

func _get_scaled_position(position_to_scale: Vector2) -> Vector2:
	return ZOOM_POSITION - ((ZOOM_POSITION - position_to_scale) * LEVEL_SCALE)
