extends Node

"""
Spawns items on demand and keeps in memory their ID
"""

var _items_list: Dictionary = {}

func spawn_item(item_id, item_name, item_position) -> void:
	var layers = owner.get_layers()
	var item = load(Director.WAREHOUSE.get_item(item_name)).instance()
	
	item.position = item_position
	
	if item is PhysicsScaler:
		item.setup({
				"id": item_id,
				"scale_coeff": owner.LEVEL_SCALE,
				"layer_array": layers.layer,
				"mask_array": layers.mask
				})
	
	_items_list[item_id] = item
	owner.spawn_entity_instance(item)


func get_item(id: int) -> Node:
	return _items_list.get(id)
