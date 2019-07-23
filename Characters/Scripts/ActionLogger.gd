extends Node

export(float) var min_direction_step: float = 0.01
export(bool) var is_logging: bool = true

onready var _start_time: int = OS.get_ticks_msec()
onready var start_position: Vector2 = get_parent().global_position

var _actions_log: Array = []

var _previous_aim_direction: Vector2 = Vector2(0.0, 0.0)
var _previous_move_direction: Vector2 = Vector2(0.0, 0.0)


func log_joystick(move_joystick: bool, direction: Vector2) -> void:
	
	if is_logging:
	
		if !move_joystick:
			if ((_previous_aim_direction - direction).abs()).length() > min_direction_step:
				_previous_aim_direction = direction
				_actions_log.append([OS.get_ticks_msec() - _start_time, "Aim", direction])
		else:
			if ((_previous_move_direction - direction).abs()).length() > min_direction_step:
				_previous_move_direction = direction
				_actions_log.append([OS.get_ticks_msec() - _start_time, "Move", direction])
		


func log_button(button_descriptor: String, pressed: bool) -> void:
	
	if is_logging:
	
		_actions_log.append([OS.get_ticks_msec() - _start_time, button_descriptor, pressed])

func get_log() -> Array:
	return _actions_log

func get_start_position() -> Vector2:
	return start_position

func print_log():
	print(_actions_log.size())
	print(_actions_log)
