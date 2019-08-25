extends Node2D

export(PackedScene) var PLAYER_LEVEL: PackedScene
export(PackedScene) var CLONE_LEVEL: PackedScene
export(PackedScene) var START_MAP: PackedScene
export(PackedScene) var ZOOM_MAP: PackedScene

export(int) var gen: int = 0
export(float) var scale_mult: float = 1

var _levels_list: Array = []
var _levels_layers_length: int = 32

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_new_gen()
		

func _ready():
	_load_player_level(START_MAP, gen)
	pass


func _new_gen() -> void:
	gen += 1
	var temp_level_list: Array = [] + _levels_list
	_levels_list = []
	for level in temp_level_list:
		_regenerate_level(level)
	_load_player_level(ZOOM_MAP, gen)
	

func _regenerate_level(level: Level) -> void:
#	var level_logs: Array = level.get_logs()
#	var level_gen: int = level.level_gen
#	level.queue_free()
	var level_datas: = level.disassemble()
	print(level_datas)
	_load_clone_level(level_datas.map, level_datas.gen, level_datas.logs)


func _load_player_level(level_map: PackedScene, level_gen: int, players_datas: Array = []) -> void:
	var level_instance = PLAYER_LEVEL.instance()

	level_instance.setup({
				"level_gen": level_gen,
				"map": level_map,
				})
	
	var level_layers = _get_level_layers(level_gen)
	
#	level_instance.layer_array = level_layers[0]
#	level_instance.mask_array = level_layers[1]
	
	_levels_list.append(level_instance)
	add_child(level_instance)


func _load_clone_level(level_map: PackedScene, level_gen: int, level_logs: Array = [[], []]) -> void:
	var level_instance = CLONE_LEVEL.instance()

	level_instance.setup({
				"level_gen": level_gen,
				"map": level_map,
				"characters_logs": level_logs[1],
				"level_logs": level_logs[0],
				"zoom_position": Vector2(250.0, 250.0),
				"scale": (float(gen - level_gen) * scale_mult) + 1.0
				})
		
#	level_instance.is_scaled = level_is_scaled
#	level_instance.zoom_position = Vector2(500.0, 250.0)
#	level_instance.level_gen = level_gen
#	level_instance.level_scale = (float(gen - level_gen) * scale_mult) + 1.0
#	level_instance.level_logs = level_logs[0]
#	level_instance.characters_logs = level_logs[1]
#	level_instance.own_packed_scene = level_to_load
	
	var level_layers = _get_level_layers(level_gen)
	
#	level_instance.layer_array = level_layers[0]
#	level_instance.mask_array = level_layers[1]
	
	_levels_list.append(level_instance)
	add_child(level_instance)

func _get_level_layers(level_gen: int) -> Array:
	
	var layers_array: Array = [[], []]

	layers_array[0].append(level_gen)
	layers_array[1].append(level_gen)
	
	return layers_array
