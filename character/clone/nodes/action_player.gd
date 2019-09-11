extends Node

onready var animation_manager: Node = owner.get_node("AnimationManager")
onready var item_manager = owner.get_node("ItemManager")
onready var _start_time: int = OS.get_ticks_msec()

var REPLAY_SPEED: float = 0.0
var LEVEL_WAREHOUSE: Node
var CURVE: = Curve2D.new()

var _actions_log: Dictionary = {}
var _current_action_step: int = 0
var _current_movement_step: int = 0


func _process(delta):
	_check_action_log(OS.get_ticks_msec() - _start_time)
	_check_position(OS.get_ticks_msec() - _start_time)


func get_actions_log() -> Dictionary:
	return _actions_log


func set_actions_log(actions_log: Dictionary) -> void:
	_actions_log = actions_log
	for i in range(1, _actions_log.movements.size() - 1):
		var tang = _actions_log.movements[i + 1].position - _actions_log.movements[i - 1].position
		var left_angle_ratio = abs(tang.tangent().angle_to(_actions_log.movements[i - 1].position - _actions_log.movements[i].position) / PI) / 4
		var right_angle_ratio = abs(tang.tangent().angle_to(_actions_log.movements[i + 1].position - _actions_log.movements[i].position) / PI) / 4
		CURVE.add_point(_actions_log.movements[i].position, - tang * left_angle_ratio, tang * right_angle_ratio)


func set_replay_speed(speed: float) -> void:
	REPLAY_SPEED = speed


func _check_position(time: int) -> void:
	if _current_movement_step + 2 < _actions_log.movements.size():
		if time / REPLAY_SPEED > _actions_log.movements[_current_movement_step + 1].time:
			_current_movement_step += 1
		
		owner.update_movement(CURVE.interpolate(_current_movement_step, 
			inverse_lerp(_actions_log.movements[_current_movement_step].time,
					_actions_log.movements[_current_movement_step + 1].time,
					time / REPLAY_SPEED
			)))


func _check_action_log(time: int):
	if _current_action_step < _actions_log.actions.size():
		if _actions_log.actions[_current_action_step].time * REPLAY_SPEED <= time:
				_do_action(_actions_log.actions[_current_action_step])
				_current_action_step += 1
				_check_action_log(time)


func _do_action(action: Dictionary):
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
			item_manager.pick_item(LEVEL_WAREHOUSE.get_item(action.args.item_id))

		"item_dropped":
			item_manager.drop_item()
		
		"grabbing_item":
			item_manager.start_grab_item(LEVEL_WAREHOUSE.get_item(action.args.item_id))


