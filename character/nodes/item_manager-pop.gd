extends Node

export(NodePath) var _right_hand_grabPoint_path: NodePath
export(NodePath) var _left_hand_grabPoint_path: NodePath

onready var grabArea = get_node("../GrabArea")
onready var _grab_points = [get_node(_right_hand_grabPoint_path), get_node(_left_hand_grabPoint_path)]

var _picked_item: Pickable

func _ready():
	$ItemPickingTimer.connect("timeout", self, "_item_picking_timeout")
	for grab_point in _grab_points:
		grab_point.connect("item_grabbed", self, "_item_grabbed")

func _unhandled_input(event):
	if event.is_action_pressed("game_grab_item"):
		if not _picked_item:
			_grab_item()
		else:
			_drop_item()

func _grab_item():
	if _check_grab_points_state("no_item"):
		var item_to_grab: Pickable = grabArea.find_closest_item(_grab_points[0].global_position)
		if not item_to_grab:
			return
		item_to_grab.pick(owner, _grab_points[0])
		_grab_points_pick_item(item_to_grab)
		_picked_item = item_to_grab
		$ItemPickingTimer.start()

func _drop_item():
	if _picked_item:
		_grab_points_drop_item()
		_picked_item.drop()
		_picked_item = null

func _item_grabbed():
	if not $ItemPickingTimer.is_stopped():
		$ItemPickingTimer.stop()

func _item_picking_timeout():
	_drop_item()

func _check_grab_points_state(state):
	var correct_state = true
	for grab_point in _grab_points:
		if grab_point.get_state() != state:
			correct_state = false
			break
	return correct_state

func _grab_points_pick_item(item):
	for grab_point in _grab_points:
		grab_point.pick_item(item)

func _grab_points_drop_item():
	for grab_point in _grab_points:
		grab_point.drop_item()