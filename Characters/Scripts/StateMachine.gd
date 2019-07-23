extends Node

enum StateList {NORMAL, STUNNED}
enum ActionList {CAN_STAND, CAN_JUMP, CAN_MOVE, CAN_ATTACK, CAN_POINT, CAN_AIM} 

const state_actions: Dictionary = {StateList.NORMAL: {"CAN_STAND":true, "CAN_JUMP":true, "CAN_WALK":true, "CAN_ATTACK":true, "CAN_POINT":true, "CAN_AIM":true}, 
		StateList.STUNNED: {"CAN_STAND":false, "CAN_JUMP":false, "CAN_WALK":false, "CAN_ATTACK":false, "CAN_POINT":false, "CAN_AIM":false}}

var state: int
var possible_actions: Dictionary

func _ready():
	update_state(StateList.NORMAL)
	print(state, " ", possible_actions)
	pass

func update_state(new_state:int) -> void:
	state = new_state
	_update_actions()

func _update_actions() -> void:
	possible_actions = state_actions[state]

