extends Level

export(PackedScene) var PlayerScene: PackedScene

var _characters_list: Array = []
var _level_logs: Array = []

func _ready():
	_spawn_player()


func disassemble() -> Dictionary:
	queue_free()
	return {"logs": get_logs(), "gen": LEVEL_GEN, "map": MAP}


func get_logs() -> Dictionary:
	var characters_log: Array = []
	
	for character in _characters_list:
		if character is Character:
			characters_log.append(character.get_replay())
	return {"level": $Logger.get_level_log(), "characters": characters_log}


func _spawn_player() -> void:
	var player_instance = PlayerScene.instance()
	var layers_array = get_layers()
	
	player_instance.setup({
		"id": $IdCounter.get_id(),
		"position": $SpawnFinder.find_spawn_position(player_instance),
		"scale_coeff": 1.0,
		"layer_array": layers_array.layer,
		"mask_array": layers_array.mask,
		})
	
	_characters_list.append(player_instance)
	add_child(player_instance)