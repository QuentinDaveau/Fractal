extends AnimationPlayer


onready var tree = get_node("../AnimationTree")

func _ready():
	tree["parameters/RunSpeed/scale"] = 2

func set_play_speed(amount: float) -> void:
	tree["parameters/TimeScale/scale"] /= amount

func move(amount:float) -> void:
	
	tree["parameters/BlendSpace1D/blend_position"] = amount