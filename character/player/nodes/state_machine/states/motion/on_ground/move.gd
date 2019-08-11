extends "on_ground.gd"

func enter():
	owner.update_velocity_limitations(MAX_VELOCITY, ACCELERATION)

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var input_direction = get_input_direction()
	if not input_direction:
		emit_signal("finished", "idle")
	owner.set_velocity(input_direction)
	.update(delta)