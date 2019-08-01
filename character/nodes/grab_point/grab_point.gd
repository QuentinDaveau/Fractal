extends PinJoint2D

signal item_grabbed()

var STATE_LIST: Array = ["no_item", "waiting_item", "has_item"]

var _state: String = "no_item"

func get_state() -> String:
	return _state

func pick_item(item) -> void:
	if _state == "no_item":
		item.connect("is_on_position", self, "_lock_item_in_hand", [], CONNECT_ONESHOT)
		_state = "waiting_item"

func drop_item() -> void:
	if _state == "no_item":
		return
	if _state == "has_item":
		set_node_b("")
	_state = "no_item"

func _lock_item_in_hand(item_path) -> void:
	if _state == "waiting_item":
		set_node_b(item_path)
		emit_signal("item_grabbed")
		_state = "has_item"