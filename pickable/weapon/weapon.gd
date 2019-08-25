class_name Weapon extends Pickable


func _scale_self() -> void:
	._scale_self()


func _attack(state) -> void:
	return


func pick(possessor: Character, item_manager, grab_point: Node2D) -> void:
	item_manager.connect("use_item", self, "_attack")
	.pick(possessor, item_manager, grab_point)


func _drop(item_manager) -> void:
	item_manager.disconnect("use_item", self, "_attack")
	._drop(item_manager)
