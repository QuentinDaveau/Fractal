extends Node2D

export(PackedScene) var init_level: PackedScene
export(PackedScene) var run_level: PackedScene
export(int) var gen: int = 0
export(float) var scale_mult: float = 1

var _levels_list: Array = []
var _levels_layers_length: int = 32

var o = 0

func _input(event):
	if event.is_action_pressed("ui_accept") and o == 0:
#		_new_gen()
		get_node("./Level/Player/BodyParts/ArmTop")._die()
		o += 1
		return
	
	if event.is_action_pressed("ui_accept") and o == 1:
#		_new_gen()
		get_node("./Level/Player/BodyParts/LegTop")._die()
		o += 1
		return
	
	if event.is_action_pressed("ui_accept") and o == 2:
#		_new_gen()
		get_node("./Level/Player/BodyParts/Head")._die()
		o += 1
		return
	
	if event.is_action_pressed("ui_accept") and o == 3:
#		_new_gen()
		get_node("./Level/Player/BodyParts/LegTop2")._die()
		o += 1
		return
		

func _ready():
	_load_level(init_level, 0, [[],[]], false)
	pass


func _new_gen() -> void:
	gen += 1
	var temp_level_list: Array = [] + _levels_list
	_levels_list = []
	for level in temp_level_list:
		_regenerate_level(level)
	_load_level(run_level, gen, [[], []], false)
	

func _regenerate_level(level: Level) -> void:
	var level_logs: Array = level.get_logs()
	var level_gen: int = level.level_gen
	level.queue_free()
	_load_level(level.own_packed_scene, level_gen, level_logs, true)
	

func _load_level(level_to_load: PackedScene, level_gen: int, level_logs: Array, level_is_scaled: bool) -> void:
	
	var level_instance: LevelScaler = level_to_load.instance()
	level_instance.is_scaled = level_is_scaled
	level_instance.zoom_position = Vector2(500.0, 250.0)
	level_instance.level_gen = level_gen
	level_instance.level_scale = (float(gen - level_gen) * scale_mult) + 1.0
	level_instance.level_logs = level_logs[0]
	level_instance.characters_logs = level_logs[1]
	level_instance.own_packed_scene = level_to_load
	
	var level_layers = _get_level_layers(level_gen)
	
	level_instance.layer_array = level_layers[0]
	level_instance.mask_array = level_layers[1]
	
	_levels_list.append(level_instance)
	add_child(level_instance)

func _get_level_layers(level_gen: int) -> Array:
	
	var layers_array: Array = [[], []]

	layers_array[0].append(level_gen)
	layers_array[1].append(level_gen)
	
	return layers_array
