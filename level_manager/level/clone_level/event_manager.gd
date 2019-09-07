extends Node

func connect_event(entity: Node) -> void:
	entity.connect("event_trigerred", self, "_event_triggered")


func _event_triggered(source_id, action, args) -> void:
	match action:
		"item_grabbed":
			