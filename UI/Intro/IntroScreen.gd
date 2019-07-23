extends Control

export(PackedScene) var scene_to_load: PackedScene

func _ready():
	pass


func _on_Button_pressed():
	var scene_to_load_instance = scene_to_load.instance()
	hide()
	get_tree().get_root().add_child(scene_to_load_instance)
