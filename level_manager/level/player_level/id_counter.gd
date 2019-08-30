extends Node

onready var _current_id: int = owner.LEVEL_GEN * 100

func get_id() -> int:
	_current_id += 1
	return _current_id - 1