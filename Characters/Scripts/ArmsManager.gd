extends Node

export(float, 0, 1) var aiming_dead_zone: float = 0.2

onready var stateMachine: Node = get_node("../StateMachine")

onready var _arm1_axle: Position2D = get_node("../Ghost/TorsoAxle/TorsoArmAxle")
onready var _arm2_axle: Position2D = get_node("../Ghost/TorsoAxle/TorsoArmAxle2")


func update_arms_direction(direction_to_match: Vector2) -> void:
	
	if !stateMachine.possible_actions.CAN_AIM:
		return
	
	if direction_to_match.length() < aiming_dead_zone:
		_arm1_axle.rotation = 0.0
		_arm2_axle.rotation = 0.0
		return
	
	if !direction_to_match.is_normalized():
		direction_to_match = direction_to_match.normalized()
	
	_arm1_axle.rotation = direction_to_match.angle() - (PI/2)
	_arm2_axle.rotation = direction_to_match.angle() - (PI/2)


