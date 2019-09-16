extends Level

export(PackedScene) var PlayerScene: PackedScene

var PLAYERS_STARTING_WEAPON: String

var _characters_list: Array = []
var _level_logs: Array = []


func setup(properties: Dictionary) -> void:
	.setup(properties)
	PLAYERS_STARTING_WEAPON = properties.players_starting_weapon


func _ready():
	for i in range(Input.get_connected_joypads().size()):
		_spawn_player(i)


func disassemble() -> Dictionary:
	queue_free()
	return {"logs": get_logs(), "gen": LEVEL_GEN, "map": MAP}


func get_logs() -> Dictionary:
	var characters_log: Array = []
	
	for character in _characters_list:
		if character is Character:
			characters_log.append(character.get_replay())
	return {"level": $Logger.get_level_log(), "characters": characters_log}


func _spawn_player(device_id: int) -> void:
	var player_instance = PlayerScene.instance()
	var layers_array = get_layers()
	var player_weapon: Pickable

	if PLAYERS_STARTING_WEAPON:
		player_weapon = $ItemSpawner.force_item_spawn(PLAYERS_STARTING_WEAPON, Vector2(-1000, -1000))
	
	player_instance.setup({
		"device_id": device_id,
		"id": $IdCounter.get_id(),
		"position": $SpawnFinder.find_spawn_position(player_instance),
		"scale_coeff": 1.0,
		"layer_array": layers_array.layer,
		"mask_array": layers_array.mask,
		"starting_weapon": player_weapon
		})
	
	_characters_list.append(player_instance)
	add_child(player_instance)