extends Node

onready var arms_manager: Node = get_node("../ArmsManager")
onready var movement_manager: Node = get_node("../MovementManager")
onready var animation_manager: Node = get_node("../AnimationManager")
onready var item_manager: Node = get_node("../ItemManager")
onready var action_logger: Node = get_node("../ActionLogger")

var controller_id: int = 0

var _movement_input_axis: Vector2 = Vector2(0.0, 0.0)
var _aiming_input_axis: Vector2 = Vector2(0.0, 0.0)


func _unhandled_input(event):
	
	if event is InputEventKey:
		if event.is_action_pressed("ui_left"):
			_movement_input_axis.x = -1
		elif event.is_action_pressed("ui_right"):
			_movement_input_axis.x = 1
		elif event.is_action_released("ui_left") && _movement_input_axis.x == -1:
			_movement_input_axis.x = 0
		elif event.is_action_released("ui_right") && _movement_input_axis.x == 1:
			_movement_input_axis.x = 0
		elif event.is_action_pressed("ui_select"):
			movement_manager.jump()
			action_logger.log_button("game_jump", true)
		
		movement_manager.update_movement(_movement_input_axis)
		animation_manager.move(_movement_input_axis.x)
		action_logger.log_joystick(true, _movement_input_axis)
	
	if event.device != controller_id:
		return
	
	if event is InputEventJoypadMotion:
		var _is_movement :bool = false
		
		if abs(event.axis_value) < 0.2:
			event.axis_value = 0.0

		if event.axis == 0:
			_movement_input_axis.x = event.axis_value
			_is_movement = true
		elif event.axis == 1:
			_movement_input_axis.y = event.axis_value
			_is_movement = true
		elif event.axis == 2:
			_aiming_input_axis.x = event.axis_value
		elif event.axis == 3:
			_aiming_input_axis.y = event.axis_value
	
		if _is_movement:
			movement_manager.update_movement(_movement_input_axis)
			animation_manager.move(_movement_input_axis.x)
			action_logger.log_joystick(true, _movement_input_axis)
		else:
			arms_manager.update_arms_direction(_aiming_input_axis)
			action_logger.log_joystick(false, _aiming_input_axis)

	elif(event is InputEventJoypadButton):
		
		if event.is_action_pressed("game_jump"):
			movement_manager.jump()
			action_logger.log_button("game_jump", true)
		
		elif event.is_action_released("game_jump"):
			movement_manager.jump_released()
			action_logger.log_button("game_jump", false)
		
		if event.is_action_pressed("game_shoot"):
			item_manager.use_item()
			action_logger.log_button("game_shoot", true)
		
		if event.is_action_pressed("game_grab_item"):
			item_manager.grab_or_drop_item()
			action_logger.log_button("game_grab_item", true)
#			action_logger.print_log()


