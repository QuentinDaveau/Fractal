extends Node

signal grab_item(id)

onready var animation_manager: Node = owner.get_node("AnimationManager")

onready var _start_time: int = OS.get_ticks_msec()

var REPLAY_SPEED: float = 0.0

var _actions_log: Dictionary = {}
var _current_action_step: int = 0
var _current_movement_step: int = 0


func _process(delta):
	
	_check_action_log(OS.get_ticks_msec() - _start_time)
	_check_position(OS.get_ticks_msec() - _start_time)
	pass


func get_actions_log() -> Dictionary:
	return _actions_log


func set_actions_log(actions_log: Dictionary) -> void:
	_actions_log = actions_log


func set_replay_speed(speed: float) -> void:
	REPLAY_SPEED = speed


func _check_position(time: int) -> void:
	if _current_movement_step + 3 < _actions_log.movements.size():
		if _actions_log.movements[_current_movement_step].time * REPLAY_SPEED <= time:
			get_parent().update_movement(_actions_log.movements[_current_movement_step + 1].position,
					_actions_log.movements[_current_movement_step + 2].position,
					(_actions_log.movements[_current_movement_step + 2].time - _actions_log.movements[_current_movement_step + 1].time) * REPLAY_SPEED,
					(_actions_log.movements[_current_movement_step + 3].time - _actions_log.movements[_current_movement_step + 2].time) * REPLAY_SPEED)
			_current_movement_step += 1


func _check_action_log(time: int):
	if _current_action_step < _actions_log.actions.size():
		if _actions_log.actions[_current_action_step].time * REPLAY_SPEED <= time:
				_do_action(_actions_log.actions[_current_action_step])
				_current_action_step += 1
				_check_action_log(time)


func _do_action(action: Dictionary):
	print(action)
	match action.action:
		
		"aim":
			var event = InputEventJoypadMotion.new()
			event.axis_value = action.args.direction.x
			event.axis = 2
			event.device = owner.get_property("DEVICE_ID")
			Input.parse_input_event(event)
			event.axis_value = action.args.direction.y
			event.axis = 3
			Input.parse_input_event(event)
			
		"move":
			animation_manager.move(action.args.direction)
			
		"item_used":
			if action.args.pressed:
				var event = InputEventAction.new()
				event.action = "game_shoot"
				event.pressed = true
				event.device = owner.get_property("DEVICE_ID")
				Input.parse_input_event(event)
		
		"item_picked":
			print("grab")
			emit_signal("grab_item", action.args.item_id)
			var event = InputEventAction.new()
			event.action = "game_grab_item"
			event.pressed = true
			event.device = owner.get_property("DEVICE_ID")
			Input.parse_input_event(event)

		"item_dropped":
			var event = InputEventAction.new()
			event.action = "game_grab_item"
			event.pressed = true
			event.device = owner.get_property("DEVICE_ID")
			Input.parse_input_event(event)


