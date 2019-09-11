extends Node2D
class_name Level


var MAP: PackedScene
var LEVEL_GEN: int = 1


func setup(properties: Dictionary) -> void:
	LEVEL_GEN = properties.level_gen
	MAP = properties.map


func _ready() -> void:
	z_index = 0 - LEVEL_GEN
	add_child(MAP.instance())


func disassemble() -> Dictionary:
	return {}


func get_logs() -> Dictionary:
	return {}


func get_layers() -> Dictionary:
	var character_layers: = {"layer": [LEVEL_GEN], "mask": []}
	
	for i in range(LEVEL_GEN + 1):
		character_layers.mask.append(i)
	
	return character_layers


