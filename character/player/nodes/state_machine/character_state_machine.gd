extends "state_machine.gd"

func _ready():
	states_map = {
		"idle": $Idle,
		"move": $Move,
		"jump": $Jump,
		"fall": $Fall,
	}

func _change_state(state_name):
	print(state_name)
	if not _active:
		return
	if state_name in ["fall", "jump"]:
		states_stack.push_front(states_map[state_name])
	._change_state(state_name)
