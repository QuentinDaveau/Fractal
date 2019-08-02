extends Position2D

signal angle_offset_updated()

var _angle_offset: float = 0.0 

func set_angle_offset(angle) -> void:
	_angle_offset = angle
	emit_signal("angle_offset_updated")
