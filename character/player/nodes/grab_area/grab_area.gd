extends Area2D


signal other_body_entered(body)

var _exceptions: = []


func _ready() -> void:
	owner.connect("body_parts_list_set", self, "_add_collision_exception")
	connect("body_entered", self, "_body_entered")


func get_other_overlapping_bodies() -> Array:
	var other_bodies: = []
	for body in get_overlapping_bodies():
		if not _exceptions.has(body):
			other_bodies.append(body)
	return other_bodies


func _add_collision_exception(bodies_array: Array) -> void:
	for body in bodies_array:
		if not _exceptions.has(body):
			_exceptions.append(body)


func _body_entered(body: PhysicsBody2D) -> void:
	if not _exceptions.has(body):
		emit_signal("other_body_entered", body)