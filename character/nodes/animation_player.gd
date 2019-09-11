extends AnimationPlayer

signal direction_changed(direction)

onready var tree = get_node("../AnimationTree")

func _ready():
	tree["parameters/RunSpeed/scale"] = 2

func set_play_speed(amount: float) -> void:
	tree["parameters/TimeScale/scale"] /= amount

func move(direction: Vector2) -> void:
	emit_signal("direction_changed", direction)
	tree["parameters/BlendSpace1D/blend_position"] = direction.x