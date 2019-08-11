extends "in_air.gd"

func enter():
	owner.update_velocity_limitations(MAX_VELOCITY, ACCELERATION)

func handle_input(event):
	return .handle_input(event)

func update(delta):
	owner.set_velocity(get_input_direction())
	.update(delta)