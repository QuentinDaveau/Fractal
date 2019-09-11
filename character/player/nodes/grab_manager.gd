extends Node

onready var GRAB_AREAS = [
		owner.get_node("BodyParts/ArmTop/ArmBottom/RightGrabArea"), 
		owner.get_node("BodyParts/ArmTop2/ArmBottom2/LeftGrabArea")]
onready var GRAB_POINTS = [
		owner.get_node("BodyParts/ArmTop/ArmBottom/RightGrabPoint"),
		owner.get_node("BodyParts/ArmTop2/ArmBottom2/LeftGrabPoint")]

onready var DEVICE_ID = owner.get_property("DEVICE_ID")
onready var STATES = GRAB_POINTS[0].STATES
onready var _state: int = STATES.no_grab


func _ready() -> void:
	STATES["grabbing"] = STATES.size()
	for grab_point in GRAB_POINTS:
		grab_point.connect("state_changed", self, "_state_changed")
	for area in GRAB_AREAS:
			area.connect("other_body_entered", self, "_body_entered")


func _unhandled_input(event):
	if not event.device == DEVICE_ID:
		return
	if event.is_action_pressed("game_shoot"):
		if _state == STATES.no_grab or _state == STATES.waiting_grab:
			if not _grab():
				_state = STATES.grabbing
	if event.is_action_released("game_shoot"):
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
			if _verify_body(body):
				return body
	return null


func _body_entered(body: PhysicsBody2D) -> void:
	if not _state == STATES.grabbing or not _verify_body(body):
		return
	_grab_points_grab(body)


func _verify_body(body: PhysicsBody2D) -> bool:
	if body is Pickable:
		if body.get_scale_coeff() != owner.get_scale_coeff():
			return true
		if body.is_picked():
			return true
	else:
		return true
	return false


func _state_changed(old_state, new_state):
	if not (old_state == STATES.waiting_grab and new_state == STATES.no_grab):
		_state = new_state