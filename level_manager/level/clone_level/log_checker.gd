extends Node

onready var _start_time: int = OS.get_ticks_msec()
onready var _item_manager = owner.get_node("ItemManager")

var LEVEL_LOG: Array = []
var REPLAY_SPEED: float = 0.0

var _current_step: int = 0

var _time_count: float = 0.0


func _process(delta):
	_time_count += delta * 1000.0
	_check_spawn_log(int(_time_count))


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
	match action.action:
		"item_spawned":
			_item_manager.spawn_item(action.args.id, action.args.name, action.args.position)



	