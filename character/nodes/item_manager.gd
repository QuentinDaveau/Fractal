extends Node

export(NodePath) var _right_hand_path: NodePath
export(NodePath) var _left_hand_path: NodePath
export(NodePath) var _right_hand_grabPoint_path: NodePath
export(NodePath) var _left_hand_grabPoint_path: NodePath

onready var grabArea = get_node("../GrabArea")

onready var _right_hand_grabPoint: Position2D = get_node(_right_hand_grabPoint_path)
onready var _left_hand_grabPoint: Position2D = get_node(_left_hand_grabPoint_path)

var _right_hand_held_item: Pickable = null
var _left_hand_held_item: Pickable = null

var _waiting_item_in_hand: bool = false

func _ready():
	_right_hand_grabPoint.set_node_a(get_node(_right_hand_path).get_path())
	_left_hand_grabPoint.set_node_a(get_node(_left_hand_path).get_path())

func use_item() -> void:
	if _right_hand_held_item is Weapon:
		_right_hand_held_item.attack()

func grab_or_drop_item() -> bool:
	
	if _right_hand_held_item == null:
		var item_to_grab: Pickable = _find_closest_item()
		
		if item_to_grab == null:
			return false
		
		_right_hand_held_item = item_to_grab
		return _pick_item()
	else:
		_right_hand_held_item.drop()
		_right_hand_grabPoint.set_node_b("")
		_right_hand_held_item.disconnect("is_on_position", self, "_lock_item_in_hand")
		_right_hand_held_item = null
		return true

func _find_closest_item() -> Pickable:
	var closest_body: Pickable
	var grabPoint_position: Vector2 = _right_hand_grabPoint.global_position
	for body in grabArea.get_overlapping_bodies():
		if body is Pickable:
			if closest_body == null:
				closest_body = body
			else:
				if grabPoint_position.distance_to(body.global_position) < grabPoint_position.distance_to(closest_body.global_position):
					body = closest_body
	return closest_body

func _pick_item() -> bool:
	if !_right_hand_held_item.pick(get_parent(), _right_hand_grabPoint):
		return false
	
	_right_hand_held_item.connect("is_on_position", self, "_lock_item_in_hand")
	_waiting_item_in_hand = true
	return true

func _lock_item_in_hand() -> void:
	if _waiting_item_in_hand:
		_right_hand_grabPoint.set_node_b(_right_hand_held_item.get_path())
		_waiting_item_in_hand = false

