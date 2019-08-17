extends Node

export(Array) var _actions_log: Array

onready var arms_manager: Node = get_node("../ArmsManager")
onready var movement_manager: Node = get_node("../MovementManager")
onready var animation_manager: Node = get_node("../AnimationManager")
onready var item_manager: Node = get_node("../ItemManager")

onready var _start_time: int = OS.get_ticks_msec()

onready var _input_scaling_coeff: float = 2

var _current_action_step: int = 0
var _current_movement_step: int = 0


func _process(delta):
	
	_check_action_log(OS.get_ticks_msec() - _start_time)
	_check_position(OS.get_ticks_msec() - _start_time)
	pass


func get_actions_log() -> Array:
	return _actions_log


func set_actions_log(actions_log: Array) -> void:
	_actions_log = actions_log


func _check_position(time: int) -> void:
	if _current_movement_step + 2 < _actions_log[1].size():
		if _actions_log[1][_current_movement_step][0] * _input_scaling_coeff <= time:
#			print(time, ", ",_actions_log[1][_current_movement_step][1])
			get_parent().desired_position = _actions_log[1][_current_movement_step][1]
			get_parent().update_movement(_actions_log[1][_current_movement_step][1], _actions_log[1][_current_movement_step + 1][1], (_actions_log[1][_current_movement_step + 1][0] - _actions_log[1][_current_movement_step][0]) * _input_scaling_coeff, (_actions_log[1][_current_movement_step + 2][0] - _actions_log[1][_current_movement_step + 1][0]) * _input_scaling_coeff)
			_current_movement_step += 1


func _check_action_log(time: int):
	if _current_action_step < _actions_log[0].size():
		if _actions_log[0][_current_action_step][0] * _input_scaling_coeff <= time:
#				print(time, ", ", _actions_log[0][_current_action_step])
				_do_action(_actions_log[0][_current_action_step])
				_current_action_step += 1
				_check_action_log(time)


func _do_action(action_array: Array):
	match action_array[1]:
		
		"Aim":
			arms_manager.update_arms_direction(action_array[2])

		"Move":
			movement_manager.update_movement(action_array[2])
			animation_manager.move(action_array[2].x)
#
#		"game_jump":
#			if action_array[2]:
#				movement_manager.jump()
#			else:
#				movement_manager.jump_released()
		
		"game_shoot":
			if action_array[2]:
				item_manager.use_item()
		
		"game_grab_item":
			if action_array[2]:
				item_manager.grab_or_drop_item()



