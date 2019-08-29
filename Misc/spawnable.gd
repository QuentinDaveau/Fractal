extends RigidBody2D
class_name Spawnable

"""
Set and contains the bound_box to check if terrain is clear for spawn
"""

export(bool) var SHOW_BOX: bool = false
export(Dictionary) var BOUND_BOX: Dictionary = {
		"height": 0.0,
		"width": 0.0,
		"offset_x": 0.0,
		"offset_y": 0.0
		}


func get_bound_box() -> Dictionary:
	return BOUND_BOX


func _draw() -> void:
	if SHOW_BOX:
		draw_rect(Rect2(Vector2((- BOUND_BOX.width / 2) + BOUND_BOX.offset_x, (- BOUND_BOX.height / 2) + BOUND_BOX.offset_y), Vector2(BOUND_BOX.width, BOUND_BOX.height)), Color.green, false)