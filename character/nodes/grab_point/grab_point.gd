extends PinJoint2D

signal state_changed(old_state, state)

enum STATES {no_grab, waiting_grab, surface_grab, item_grab}

var _state: int = STATES.no_grab


func get_state() -> int:
	return _state


func pick_item(item) -> void:
	if _state == STATES.no_grab:
		if not item.is_connected("is_on_position", self, "_lock_grab_in_hand"):
			item.connect("is_on_position", self, "_lock_grab_in_hand", [], CONNECT_ONESHOT)
		_update_state(STATES.waiting_grab)


func drop() -> void:
	if _state == STATES.no_grab:
		return
	if _state == STATES.surface_grab or _state == STATES.item_grab:
		disable_collision = false
		set_node_b("")
	_update_state(STATES.no_grab)


func _update_state(new_state) -> void:
	emit_signal("state_changed", _state, new_state)
	_state = new_state


func _lock_grab_in_hand(grab_path: NodePath) -> void:
	if _state == STATES.waiting_grab:
		disable_collision = true
		bias = 0.9
		set_node_b(grab_path)
		_update_state(STATES.item_grab)


func grab_surface(grab_path: NodePath) -> void:
	if _state == STATES.no_grab or _state == STATES.waiting_grab:
		disable_collision = false
		bias = 0.4
		set_node_b(grab_path)
		_update_state(STATES.surface_grab)
