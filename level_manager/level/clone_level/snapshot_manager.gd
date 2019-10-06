extends Node


func take_snapshot() -> Array:
	var snap_list: = []
	for entity in owner.get_node("Entities"):
		if entity is Entity:
			snap_list.append({
					"name": entity.get_entity_name(), "id": entity.get_id(), 
					"snapshot": entity.get_snapshot()})
	return snap_list
