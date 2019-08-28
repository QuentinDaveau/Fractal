extends Node

export(NodePath) var _right_hand_grabPoint_path: NodePath
export(NodePath) var _left_hand_grabPoint_path: NodePath

onready var GRAB_AREAS = [
		owner.get_node("BodyParts/ArmTop/ArmBottom/RightGrabArea"), 
		owner.get_node("BodyParts/ArmTop2/ArmBottom2/LeftGrabArea")]

onready var GRAB_POINTS = [get_node(_right_hand_grabPoint_path), get_node(_left_hand_grabPoint_path)]
onready var STATES = GRAB_POINTS[0].STATES
onready var _state: int = STATES.no_grab


func _ready() -> void:
	STATES["grabbing"] = STATES.size()
	for grab_point in GRAB_POINTS:
		grab_point.connect("state_changed", self, "_state_changed")
	for area in GRAB_AREAS:
			area.connect("other_body_entered", self, "_body_entered")


func _unhandled_input(event):
	if event.is_action_pressed("game_grab_item"):
		if _state == STATES.no_grab or _state == STATES.waiting_grab:
			if not _grab():
				_state = STATES.grabbing
	if event.is_action_released("game_grab_item"):
		if _state == STATES.surface_grab:
			_grab_points_drop()
		_state = STATES.no_grab


func _grab() -> bool:
	var body = _get_object()
	if body:
		_grab_points_grab(body)
		return true
	return false


func _grab_points_grab(surface):
	for grab_point in GRAB_POINTS:
		grab_point.grab_surface(surface.get_path())


func _grab_points_drop():
	for grab_point in GRAB_POINTS:
		grab_point.drop()


func _get_object() -> PhysicsBody2D:
	for area in GRAB_AREAS:
		for body in area.get_other_overlapping_bodies():
			if not body is Pickable:
				return body
	return null


func _body_entered(body: PhysicsBody2D) -> void:
	if not _state == STATES.grabbing or body is Pickable:
		return
	_grab_points_grab(body)


func _state_changed(old_state, new_state):
	if not (old_state == STATES.waiting_grab and new_state == STATES.no_grab):
		_state = new_state