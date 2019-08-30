extends Node

onready var _start_time: int = OS.get_ticks_msec()

var LEVEL_LOG: Array = []


func _ready() -> void:
	owner.get_node("ItemSpawner").connect("item_spawned", self, "_item_spawned")


func get_level_log() -> Array:
	return LEVEL_LOG


func _item_spawned(item_name, item_id, item_position) -> void:
	LEVEL_LOG.append({
			"time": OS.get_ticks_msec() - _start_time,
			"action": "item_spawned", 
			"args": {"name": item_name, "id": item_id, "position": item_position}
			})