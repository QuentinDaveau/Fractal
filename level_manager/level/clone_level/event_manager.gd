extends Node

signal do_action(

onready var _item_manager = owner.get_node("ItemManager")


func connect_event(entity: Node) -> void:
	entity.connect("event_trigerred", self, "_event_triggered")
	connect(


func _event_triggered(source_id, action, args) -> void:
	match action:
		"item_grabbed":
			_item_manager.get_item(args.item_id).respawn(source_id)