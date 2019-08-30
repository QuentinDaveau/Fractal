extends Node

onready var spawn_finder = owner.get_node("SpawnFinder")

var COOLDOWN_RANGE: Array = [3.0, 8.0]


func _ready() -> void:
	randomize()
	$CoolDown.connect("timeout", self, "_cooldown_timeout")
	_start_cooldown()


func _start_cooldown() -> void:
	$CoolDown.start(rand_range(COOLDOWN_RANGE[0], COOLDOWN_RANGE[1]))


func _cooldown_timeout() -> void:
	_spawn_item()
	_start_cooldown()


func _spawn_item() -> void:
	var layers = owner.get_layers()
	var item = load(Director.WAREHOUSE.get_random_item()).instance()
	
	item.position = spawn_finder.find_spawn_position(item)
	
	if item is PhysicsScaler:
		item.setup({
				"scale_coeff": 1.0,
				"layer_array": layers.layer,
				"mask_array": layers.mask
				})
	owner.add_child(item)