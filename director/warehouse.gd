extends Node

var ITEMS: Dictionary = {
		"enabled": {
			"test_gun": {"path": "res://pickable/weapon/firearm/test_gun/TestGun.tscn", "type": "weapon"}
			}
		}


func get_random_item(type: String = "weapon") -> PackedScene:
	var random = randi()%(ITEMS.enabled.size())
	randomize()
	while not ITEMS.enabled[ITEMS.enabled.keys()[random]].type == type:
		random = randi()%(ITEMS.enabled.size()+1)
	return ITEMS.enabled[ITEMS.enabled.keys()[random]].path


func get_item(item_name: String) -> PackedScene:
	return ITEMS.enabled.get(item_name).path