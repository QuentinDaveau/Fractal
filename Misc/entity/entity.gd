extends RigidBody2D
class_name Entity

"""
Contains the ID and the name of the entity, as well as the base snapshot function
"""

export(String) var OBJECT_NAME: String
var ID: int


func setup(properties: Dictionary) -> void:
	if not properties.has("id"):
		ID = -1
		return
	ID = properties.id


func get_id() -> int:
	return ID


func get_entity_name() -> String:
	return OBJECT_NAME


func get_snapshot(snap_dict: Dictionary = {}) -> Dictionary:
	snap_dict["position"] = global_position
	snap_dict["rotation"] = global_rotation
	snap_dict["linear_velocity"] = linear_velocity
	snap_dict["angular_velocity"] = angular_velocity
	return snap_dict