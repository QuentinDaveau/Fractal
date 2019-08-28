extends Node

signal use_item
signal drop_item(this)
signal item_picked

export(NodePath) var _right_hand_grabPoint_path: NodePath
export(NodePath) var _left_hand_grabPoint_path: NodePath

onready var PICK_AREAS = {
		"right": owner.get_node("BodyParts/ArmTop/ArmBottom/RightPickArea"), 
		"left": owner.get_node("BodyParts/ArmTop2/ArmBottom2/LeftPickArea")}

onready var GRAB_POINTS = [get_node(_right_hand_grabPoint_path), get_node(_left_hand_grabPoint_path)]
onready var STATES = GRAB_POINTS[0].STATES

var _can_grab_items: bool = true
var _has_item: bool = false
var _grabbed_item_id: int = 0


func _ready():
	$ItemPickingTimer.connect("timeout", self, "_item_picking_timeout")
	for grab_point in GRAB_POINTS:
		grab_point.connect("state_changed", self, "_state_changed")


func _unhandled_input(event):
	if not _can_grab_items or event.device != owner.get_property("DEVICE_ID"):
		return
	if event.is_action_pressed("game_grab_item"):
		if not _has_item:
			_pick_item()
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


func _pick_item():
	if _check_grab_points_state(STATES.no_grab):
		var item_to_grab: Pickable = _find_closest_item(GRAB_POINTS[0].global_position)
		if not item_to_grab:
			return
		item_to_grab.pick(owner, self, GRAB_POINTS[0])
		_grab_points_pick_item(item_to_grab)
		_grabbed_item_id = item_to_grab.get_id()
		$ItemPickingTimer.start()


func _drop_item():
	_grab_points_drop_item()
	emit_signal("drop_item", self)
	_has_item = false


func _state_changed(old_state, new_state) -> void:
	if old_state == STATES.waiting_grab && new_state == STATES.item_grab:
		if not $ItemPickingTimer.is_stopped():
			$ItemPickingTimer.stop()
			emit_signal("item_picked", _grabbed_item_id)
			_has_item = true
	if new_state == STATES.surface_grab:
		$ItemPickingTimer.stop()
		emit_signal("drop_item", self)
		_has_item = false


func _item_picking_timeout():
	_drop_item()


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


func _find_closest_item(grab_point_position: Vector2) -> Pickable:
	var closest_body: Pickable
	for body in _pick_areas_get_items():
		if body.is_free():
			if closest_body == null:
				closest_body = body
			else:
				if grab_point_position.distance_to(body.global_position) < grab_point_position.distance_to(closest_body.global_position):
					body = closest_body
	return closest_body


func _pick_areas_get_items() -> Array:
	var pickables_list: = []
	for body in PICK_AREAS.right.get_overlapping_bodies():
		if body is Pickable:
			pickables_list.append(body)
	for body in PICK_AREAS.left.get_overlapping_bodies():
		if body is Pickable:
			if not pickables_list.has(body):
				pickables_list.append(body)
	return pickables_list
