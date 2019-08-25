extends LevelScaler
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


func get_logs() -> Array:
	return []


func _get_character_layers() -> Array:
	var character_layers: Array = [[LEVEL_GEN], []]
	
	for i in range(LEVEL_GEN + 1):
		character_layers[1].append(i)
	
	return character_layers


