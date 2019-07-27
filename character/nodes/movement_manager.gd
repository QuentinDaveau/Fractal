extends Node

export(float, 0, 1) var movement_dead_zone: float = 0.2
export(float) var movement_speed: float
export(float) var jump_power: float
export(float) var jump_hold_power: float
export(float) var run_leaning_angle: float = 10.0

onready var character: RigidBody2D = get_parent()
onready var stateMachine: Node = get_node("../StateMachine")
onready var torsoAxle: Position2D = get_node("../Ghost/TorsoAxle")

onready var _movement_scaling_coeff: float = get_parent().speed_coeff * get_parent().scale_coeff
onready var _jump_scaling_coeff: float = get_parent().body_mass_mult * get_parent().scale_coeff

var _can_jump: bool = true


func jump() -> void:
	if stateMachine.possible_actions.CAN_JUMP:
		if _can_jump:
			print("jump")
			character.jump(-abs(jump_power) * _jump_scaling_coeff, -abs(jump_hold_power)  * _jump_scaling_coeff)
			_can_jump = false


func jump_released() -> void:
	character.release_jump()
	pass


func update_movement(input_vect:Vector2) -> void:
	
	if input_vect.length() < movement_dead_zone:
		character.forceVector = Vector2(0.0, 0.0)
		torsoAxle.rotation_degrees = 0.0
		return
	
	if stateMachine.possible_actions.CAN_WALK:
		character.forceVector = input_vect * movement_speed / _movement_scaling_coeff
		torsoAxle.rotation_degrees = lerp(-run_leaning_angle, run_leaning_angle, (1 + input_vect.x)/2)


func _on_RayCast2D_collision_entered() -> void:
	_can_jump = true
	


func _on_RayCast2D_collision_exited() -> void:
	_can_jump = false
