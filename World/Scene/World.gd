extends Node

export(PackedScene) var player_clone: PackedScene
export(PackedScene) var player_scene: PackedScene

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_spawn_clone()
#		_increase_scale()
	

func _spawn_player() -> void:
	var test = player_scene.instance()
	test.position = Vector2(50.0, 50.0)
	add_child(test)

func _increase_scale() -> void:
	var player_scale = find_node("*er*", false, false).scale_coeff
	find_node("*er*", false, false).queue_free()
	var new_player_instance = player_scene.instance()
	new_player_instance.global_position = Vector2(66.0, 47.0)
	new_player_instance.scale_coeff = player_scale + 1
	new_player_instance.set_name("rerr")
	add_child(new_player_instance)

func _spawn_clone() -> void:
	var actions_log = $Character/ActionLogger.get_log()

#		print(actions_log)

	var start_position = $Character/ActionLogger.get_start_position()
	
	$Character/ActionLogger.is_logging = false

#		$Character.queue_free()

	var player_clone_instance = player_clone.instance()
#	player_clone_instance._custom_scale_self()
	player_clone_instance.get_node("ActionPlayer").actions_log = actions_log
	player_clone_instance.global_position = start_position
	player_clone_instance.scale_coeff = 2.0

	add_child(player_clone_instance)