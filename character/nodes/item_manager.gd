extends Node

signal use_item
signal drop_item
signal item_picked

export(NodePath) var _right_hand_grabPoint_path: NodePath
export(NodePath) var _left_hand_grabPoint_path: NodePath

onready var GRAB_AREA = get_node("../GrabArea")
onready var GRAB_POINTS = [get_node(_right_hand_grabPoint_path), get_node(_left_hand_grabPoint_path)]

var _can_grab_items: bool = true
var _has_item: bool = false
var _grabbed_item_id: int = 0


func _ready():
	$ItemPickingTimer.connect("timeout", self, "_item_picking_timeout")
	for grab_point in GRAB_POINTS:
		grab_point.connect("item_grabbed", self, "_item_grabbed")


func _unhandled_input(event):
	if not _can_grab_items or event.device != owner.get_property("DEVICE_ID"):
		return
	if event.is_action_pressed("game_grab_item"):
		if not _has_item:
			_grab_item()
		else:
			_drop_item()
	if event.is_action_pressed("game_shoot"):
		if _has_item:
			emit_signal("use_item", true)
	if event.is_action_released("game_shoot"):
		if _has_item:
			emit_signal("use_item", false)

func allow_item_picking(value: bool) -> void:
	_can_grab_items = value
	if not value:
		_drop_item()

func _grab_item():
	if _check_grab_points_state("no_item"):
		var item_to_grab: Pickable = GRAB_AREA.find_closest_item(GRAB_POINTS[0].global_position)
		if not item_to_grab:
			return
		item_to_grab.pick(owner, self, GRAB_POINTS[0])
		_grab_points_pick_item(item_to_grab)
		_grabbed_item_id = item_to_grab.get_id()
		$ItemPickingTimer.start()

func _drop_item():
	_grab_points_drop_item()
	emit_signal("drop_item")
	_has_item = false

func _item_grabbed():
	if not $ItemPickingTimer.is_stopped():
		$ItemPickingTimer.stop()
		emit_signal("item_picked", _grabbed_item_id)
		_has_item = true

func _item_picking_timeout():
	_drop_item()

func _check_grab_points_state(state):
	var correct_state = true
	for grab_point in GRAB_POINTS:
		if grab_point.get_state() != state:
			correct_state = false
			break
	return correct_state

func _grab_points_pick_item(item):
	for grab_point in GRAB_POINTS:
		grab_point.pick_item(item)

func _grab_points_drop_item():
	for grab_point in GRAB_POINTS:
		grab_point.drop_item()


