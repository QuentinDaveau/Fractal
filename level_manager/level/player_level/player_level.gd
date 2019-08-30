extends Level

export(PackedScene) var PlayerScene: PackedScene

var _characters_list: Array = []
var _level_logs: Array = []

func _ready():
	_spawn_player()


func disassemble() -> Dictionary:
	queue_free()
	return {"logs": _get_logs(), "gen": LEVEL_GEN, "map": MAP}


func _get_logs() -> Array:
	var characters_log_array: Array = []
	
	for character in _characters_list:
		if character is Character:
			characters_log_array.append(character.get_replay())
	return [_level_logs, characters_log_array]


func _spawn_player() -> void:
	var player_instance = PlayerScene.instance()
	var layers_array = _get_character_layers()
	
	player_instance.setup({
		"position": $SpawnFinder.find_spawn_position(player_instance),
		"scale_coeff": 1.0,
		"layer_array": layers_array.layer,
		"mask_array": layers_array.mask,
		})
	
	_characters_list.append(player_instance)
	add_child(player_instance)