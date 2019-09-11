extends Node

signal use_item
signal drop_item(this)

export(NodePath) var _right_hand_grabPoint_path: NodePath
export(NodePath) var _left_hand_grabPoint_path: NodePath

onready var GRAB_POINTS = [get_node(_right_hand_grabPoint_path), get_node(_left_hand_grabPoint_path)]
onready var STATES = GRAB_POINTS[0].STATES

var _can_grab_items: bool = true
var _has_item: bool = false


func _ready():
	for grab_point in GRAB_POINTS:
		grab_point.connect("state_changed", self, "_state_changed")


func _unhandled_input(event):
	if not _can_grab_items or event.device != owner.get_property("DEVICE_ID"):
		return
	if event.is_action_pressed("game_shoot"):
		if _has_item:
			emit_signal("use_item", true)
	if event.is_action_released("game_shoot"):
		if _has_item:
			emit_signal("use_item", false)


func start_grab_item(item_to_pick: Pickable) -> void:
	print("grab")


func pick_item(item_to_pick: Pickable) -> void:
	if _check_grab_points_state(STATES.no_grab):
		if not item_to_pick:
			return
		item_to_pick.pick(owner, self, GRAB_POINTS[0], 0.01)
		_grab_points_pick_item(item_to_pick)


func drop_item():
	_grab_points_drop_item()
	emit_signal("drop_item", self)
	_has_item = false


func _state_changed(old_state, new_state) -> void:
	if old_state == STATES.waiting_grab && new_state == STATES.item_grab:
		_has_item = true
	if new_state == STATES.surface_grab:
		emit_signal("drop_item", self)
		_has_item = false


func _check_grab_points_state(state):
	var correct_state = true
	for grab_point in GRAB_POINTS:
		if grab_point.get_state() != state:
			correct_state = false
			break
	return correct_state


func _grab_points_pick_item(item) -> void:
	for grab_point in GRAB_POINTS:
		grab_point.pick_item(item)


func _grab_points_drop_item() -> void:
	for grab_point in GRAB_POINTS:
		grab_point.drop()
