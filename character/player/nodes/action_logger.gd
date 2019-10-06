extends Node

export(float) var MIN_DIRECTION_STEP: float = 0.01
export(bool) var is_logging: bool = true
export(float) var position_log_delay_ms: float = 100

onready var start_position: Vector2 = get_parent().global_position
onready var _start_time: int = OS.get_ticks_msec()

var MIN_POSITION_STEP: int = 10

var _actions_log: Array = []
var _movements_log: Array = []

var _previous_aim_direction: Vector2 = Vector2(0.0, 0.0)
var _previous_move_direction: Vector2 = Vector2(0.0, 0.0)

var _movement_log_step: int = 0


func _ready() -> void:
	owner.get_node("ItemManager").connect("use_item", self, "_item_used")
	owner.get_node("ItemManager").connect("drop_item", self, "_item_dropped")
	owner.get_node("ItemManager").connect("item_picked", self, "_item_picked")
	owner.get_node("ItemManager").connect("grabbing_item", self, "_grabbing_item")
	owner.get_node("ArmsStateMachine").connect("direction_changed", self, "_arms_direction_changed")
	owner.get_node("AnimationManager").connect("direction_changed", self, "_movement_direction_changed")


func _physics_process(delta):
	if OS.get_ticks_msec() - _start_time > position_log_delay_ms * _movement_log_step:
		_log_movement()
		_movement_log_step += 1


func get_log() -> Dictionary:
	return {"actions": _actions_log, "movements": _movements_log}


func get_movement_log() -> Array:
	return _movements_log


func get_start_position() -> Vector2:
	return start_position


func _log_movement() -> void:
	if _movements_log.size() > 0:
		if (owner.global_position - _movements_log[-1].position).length() < MIN_POSITION_STEP:
			return
	_movements_log.append({"time": OS.get_ticks_msec() - _start_time, "position": owner.global_position})


func _item_used(pressed) -> void:
	_log_action("item_used", {"pressed": pressed})


func _item_dropped(item_manager) -> void:
	_log_action("item_dropped")


func _item_picked(item_id) -> void:
	_log_action("item_picked", {"item_id": item_id})


func _grabbing_item(item_id) -> void:
	_log_action("grabbing_item", {"item_id": item_id})


func _movement_direction_changed(direction) -> void:
	if is_logging:
		if ((_previous_move_direction - direction).abs()).length() > MIN_DIRECTION_STEP * 5:
			_previous_move_direction = direction
			_log_action("move", {"direction": direction})


func _arms_direction_changed(direction) -> void:
	if is_logging:
		if ((_previous_aim_direction - direction).abs()).length() > MIN_DIRECTION_STEP:
			_previous_aim_direction = direction
			_log_action("aim", {"direction": direction})


func _log_action(action_descriptor: String, args = {}) -> void:
	if is_logging:
		_actions_log.append({"time": OS.get_ticks_msec() - _start_time, "action": action_descriptor, "args": args})
