extends Node

signal item_spawned(name, id, position)

onready var spawn_finder = owner.get_node("SpawnFinder")
onready var id_counter = owner.get_node("IdCounter")

var COOLDOWN_RANGE: Array = [3.0, 5.0]


func _ready() -> void:
	randomize()
	$CoolDown.connect("timeout", self, "_cooldown_timeout")
	_start_cooldown()


func force_item_spawn(item_name: String, item_position: Vector2) -> Pickable:
	var item = load(Director.WAREHOUSE.get_item(item_name)).instance()
	return _spawn_item(item, item_position)


func _start_cooldown() -> void:
	$CoolDown.start(rand_range(COOLDOWN_RANGE[0], COOLDOWN_RANGE[1]))


func _cooldown_timeout() -> void:
	_spawn_random_item()
	_start_cooldown()


func _spawn_random_item() -> void:
	var item = load(Director.WAREHOUSE.get_random_item()).instance()
	
	_spawn_item(item, spawn_finder.find_spawn_position(item))


func _spawn_item(item: Pickable, item_position: Vector2) -> Pickable:
	var layers = owner.get_layers()
	
	item.position = item_position
	item.setup({
			"id": id_counter.get_id(),
			"scale_coeff": 1.0,
			"layer_array": layers.layer,
			"mask_array": layers.mask
			})
	
	emit_signal("item_spawned", item.get_entity_name(), item.get_id(), item.position)
	owner.add_child(item)
	
	return item