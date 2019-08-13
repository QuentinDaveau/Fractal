extends LevelScaler
class_name Level


export(PackedScene) var PlayerScene: PackedScene
export(PackedScene) var CloneScene: PackedScene

var own_packed_scene: PackedScene

var characters_logs: Array = []
var level_logs: Array = []
var level_gen: int = 1

var _characters_list: Array = []


func _ready():
	
	z_index = 0 - level_gen
	
	if !is_scaled:
		_spawn_players()
		return
	
	if characters_logs.size() > 0:
		for character_datas in characters_logs:
			_spawn_clone(character_datas)


func get_logs() -> Array:
	if is_scaled:
		return [level_logs, characters_logs]
	else:
		var characters_log_array: Array = []
		for character in _characters_list:
			if character is Character:
				characters_log_array.append(character.get_replay())
				print(character.get_replay()[1][1])
		return [level_logs, characters_log_array]


func _spawn_clone(character_datas: Array) -> void:
	
	var character_instance = CloneScene.instance()
	
	var layers_array = _get_character_layers()
	character_instance.setup({"position": _get_scaled_position(character_datas[0]),
	 "scale_coeff": level_scale,
	 "layer_array": layers_array[0],
	 "mask_array": layers_array[0]})
	
#	character_instance.position = _get_scaled_position(character_datas[0])
#
#	character_instance.speed_coeff = level_scale
#	character_instance.is_scaled = true
#	character_instance.scale_coeff = level_scale
	
	character_instance.zoom_position = zoom_position
	
	_set_character_layers(character_instance)
	
	character_instance.set_replay(character_datas[1])
	
	add_child(character_instance)


func _spawn_players() -> void:
	
	var player_instance = PlayerScene.instance()
	
	player_instance._scale_coeff = 1.0
	player_instance.is_scaled = false
	player_instance.position = $PlayerSpawn.position
	
	_set_character_layers(player_instance)
	
	_characters_list.append(player_instance)
	
	add_child(player_instance)


func _set_character_layers(character: PhysicsScaler) -> void:
	
	var layers_array = _get_character_layers()
	
	character._layer_array = layers_array[0]
	character._mask_array = layers_array[1]


func _get_character_layers() -> Array:
	
	var character_layers: Array = [[level_gen], []]
	
	for i in range(level_gen + 1):
		character_layers[1].append(i)
	
	return character_layers


