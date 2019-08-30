extends Node

onready var _start_time: int = OS.get_ticks_msec()

var LEVEL_LOG: Array = []
var REPLAY_SPEED: float = 0.0

var _current_step: int = 0


func _process(delta):
	_check_spawn_log(OS.get_ticks_msec() - _start_time)


func set_level_log(level_log: Array) -> void:
	LEVEL_LOG = level_log


func get_level_log() -> Array:
	return LEVEL_LOG


func set_replay_speed(speed: float) -> void:
	REPLAY_SPEED = speed


func _check_spawn_log(time: int):
	if _current_step < LEVEL_LOG.size():
		if LEVEL_LOG[_current_step].time * REPLAY_SPEED <= time:
				_do_action(LEVEL_LOG[_current_step])
				_current_step += 1
				_check_spawn_log(time)


func _do_action(action: Dictionary):
	print(action)
	match action.action:
		"item_spawned":
			_spawn_item(action.args.id, action.args.name, action.args.position)


func _spawn_item(item_id, item_name, item_position) -> void:
	var layers = owner.get_layers()
	var item = load(Director.WAREHOUSE.get_item(item_name)).instance()
	
	item.position = item_position
	
	if item is PhysicsScaler:
		item.setup({
				"id": item_id,
				"scale_coeff": owner.LEVEL_SCALE,
				"layer_array": layers.layer,
				"mask_array": layers.mask
				})
	
	owner.add_child(item)
	