extends Level

onready var CLONE_SCENE = Director.WAREHOUSE.get_character("clone")

var ZOOM_POSITION: Vector2
var LEVEL_SCALE: float = 1.0

var _clone_spawn_count: int = 0


func setup(properties: Dictionary) -> void:
	$LogChecker.set_logs(properties.level_logs, properties.characters_logs)
	ZOOM_POSITION = properties.zoom_position
	LEVEL_SCALE = properties.scale
	scale = Vector2.ONE * LEVEL_SCALE
	position = ZOOM_POSITION - (ZOOM_POSITION * LEVEL_SCALE)
	$LogChecker.set_replay_speed(pow(LEVEL_SCALE, 2))
	.setup(properties)


func disassemble() -> Dictionary:
	queue_free()
	return {"logs": {"level": $LogChecker.get_level_log(), "characters": $LogChecker.get_characters_log()}, "gen": LEVEL_GEN, "map": MAP}


func get_logs() -> Dictionary:
	return {"level": $LogChecker.get_level_log(), "characters": $LogChecker.get_characters_log()}


func spawn_clone(character_datas: Dictionary) -> void:
	
	var clone_instance = CLONE_SCENE.instance()
	var layers_array = get_layers()
	
	clone_instance.scale = Vector2.ONE / LEVEL_SCALE
	clone_instance.setup({
		"id": character_datas.id,
		"position": character_datas.start_position,
		"scale_coeff": LEVEL_SCALE,
		"layer_array": layers_array.layer,
		"mask_array": layers_array.mask,
		"replay": character_datas.logs,
		"zoom_position": ZOOM_POSITION,
		"level_warehouse": $ItemManager,
		"device_id": - 100 - _clone_spawn_count - (LEVEL_GEN * 100)
		})
	
	_clone_spawn_count += 1
	spawn_entity_instance(clone_instance)


func _get_scaled_position(position_to_scale: Vector2) -> Vector2:
	return ZOOM_POSITION - ((ZOOM_POSITION - position_to_scale) * LEVEL_SCALE)
