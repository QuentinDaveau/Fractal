extends RigidBody2D
class_name Entity

"""
Contains the ID and the name of the entity
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