extends "./state_machine.gd"

func _ready():
	states_map = {
		"idle": $Idle,
		"move": $Move,
		"jump": $Jump,
		"stagger": $Stagger,
	}

func _change_state(state_name):
	if not _active:
		return
	if state_name in ["stagger", "jump"]:
		states_stack.push_front(states_map[state_name])
	if state_name == "jump" and current_state == $Move:
		$Jump.initialize($Move.speed, $Move.velocity)
	._change_state(state_name)
