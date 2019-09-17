extends Node

onready var _start_time: int = OS.get_ticks_msec()

var LEVEL_LOG: Array = []


func _ready() -> void:
	owner.get_node("ItemSpawner").connect("item_spawned", self, "_item_spawned")
	owner.connect("player_spawned", self, "_player_spawned")


func get_level_log() -> Array:
	return LEVEL_LOG


func _player_spawned(player_datas) -> void:
	_log("player_spawned", player_datas)


func _item_spawned(item_name, item_id, item_position) -> void:
	_log("item_spawned", {"name": item_name, "id": item_id, "position": item_position})


func _log(action, args) -> void:
	LEVEL_LOG.append({
			"time": OS.get_ticks_msec() - _start_time,
			"action": action, 
			"args": args
			})