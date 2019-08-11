extends "../state.gd"

onready var DEAD_ZONE: float = owner.get_property("DEAD_ZONE")
var _input_direction: = Vector2()

func handle_input(event):
	if event is InputEventJoypadMotion:
		_update_input_direction(event)

func _update_input_direction(event) -> void:
	if abs(event.axis_value) < DEAD_ZONE:
		event.axis_value = 0.0
	if event.axis == 0:
		_input_direction.x = event.axis_value
	elif event.axis == 1:
		_input_direction.y = event.axis_value

func get_input_direction() -> Vector2:
	return _input_direction

func clear_input_direction() -> void:
	_input_direction = Vector2()

func init_input_direction(controller_id: int) -> void:
	_input_direction.x = Input.get_joy_axis(controller_id, 0)
	_input_direction.y = Input.get_joy_axis(controller_id, 1)
	if abs(_input_direction.x) < DEAD_ZONE:
		_input_direction.x = 0.0
	if abs(_input_direction.y) < DEAD_ZONE:
		_input_direction.y = 0.0