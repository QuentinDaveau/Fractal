extends Node2D

export(PackedScene) var PLAYER_LEVEL: PackedScene
export(PackedScene) var CLONE_LEVEL: PackedScene
export(PackedScene) var START_MAP: PackedScene
export(PackedScene) var ZOOM_MAP: PackedScene

export(int) var gen: int = 0
export(float) var scale_mult: float = 2.0

var _levels_list: Array = []
var _levels_layers_length: int = 32


func _input(event):
	if event.is_action_pressed("ui_accept"):
		_new_gen()


func _ready():
	_load_player_level(START_MAP, gen)


func _new_gen() -> void:
	gen += 1
	var temp_level_list: Array = [] + _levels_list
	_levels_list = []
	for level in temp_level_list:
		_regenerate_level(level)
	_load_player_level(ZOOM_MAP, gen)
	

func _regenerate_level(level: Level) -> void:
	var level_datas: = level.disassemble()
	_load_clone_level(level_datas.map, level_datas.gen, level_datas.logs)


func _load_player_level(level_map: PackedScene, level_gen: int, players_datas: Array = []) -> void:
	var level_instance = PLAYER_LEVEL.instance()
	
	level_instance.setup({
				"level_gen": level_gen,
				"map": level_map,
				})
	_levels_list.append(level_instance)
	add_child(level_instance)


func _load_clone_level(level_map: PackedScene, level_gen: int, level_logs: Dictionary) -> void:
	var level_instance = CLONE_LEVEL.instance()
	level_instance.setup({
				"level_gen": level_gen,
				"map": level_map,
				"characters_logs": level_logs.characters,
				"level_logs": level_logs.level,
				"zoom_position": Vector2(250.0, 250.0),
				"scale": pow(scale_mult, gen - level_gen)
				})
	
	_levels_list.append(level_instance)
	add_child(level_instance)

func _get_level_layers(level_gen: int) -> Array:
	
	var layers_array: Array = [[], []]

	layers_array[0].append(level_gen)
	layers_array[1].append(level_gen)
	
	return layers_array
