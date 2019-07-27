extends Character
class_name Player


func get_replay() -> Array:
	return [$ActionLogger.get_start_position(), $ActionLogger.get_log()]
