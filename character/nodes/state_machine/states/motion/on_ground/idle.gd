extends "on_ground.gd"

func enter():
	owner.update_velocity_limitations(MAX_VELOCITY, DAMPENING)

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var input_direction = get_input_direction()
	if input_direction:
		emit_signal("finished", "move")
	.update(delta)