extends Level

export(PackedScene) var CLONE_SCENE: PackedScene

var CHARACTER_LOGS: Array = []
var ZOOM_POSITION: Vector2
var LEVEL_SCALE: float = 1.0


func setup(properties: Dictionary) -> void:
	CHARACTER_LOGS = properties.characters_logs
	$LogChecker.set_level_log(properties.level_logs)
	ZOOM_POSITION = properties.zoom_position
	LEVEL_SCALE = properties.scale
	scale = Vector2.ONE * LEVEL_SCALE
	position = ZOOM_POSITION - (ZOOM_POSITION * LEVEL_SCALE)
	$LogChecker.set_replay_speed(pow(LEVEL_SCALE, 2))
	.setup(properties)


func _ready():
	if CHARACTER_LOGS.size() > 0:
		for character_datas in CHARACTER_LOGS:
			_spawn_clone(character_datas)


func disassemble() -> Dictionary:
	queue_free()
	return {"logs": {"level": $LogChecker.get_level_log(), "characters": CHARACTER_LOGS}, "gen": LEVEL_GEN, "map": MAP}


func get_logs() -> Dictionary:
	return {"level": $LogChecker.get_level_log(), "characters": CHARACTER_LOGS}


func _spawn_clone(character_datas: Dictionary) -> void:
	
	var clone_instance = CLONE_SCENE.instance()
	clone_instance.scale = Vector2.ONE / LEVEL_SCALE
	var layers_array = get_layers()
	
	clone_instance.setup({
		"id": character_datas.id,
		"position": character_datas.start_position,
		"scale_coeff": LEVEL_SCALE,
		"layer_array": layers_array.layer,
		"mask_array": layers_array.mask,
		"replay": character_datas.logs,
		"zoom_position": ZOOM_POSITION
		})
	
	add_child(clone_instance)

func _get_scaled_position(position_to_scale: Vector2) -> Vector2:
	return ZOOM_POSITION - ((ZOOM_POSITION - position_to_scale) * LEVEL_SCALE)
