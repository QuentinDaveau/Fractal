extends "in_air.gd"

export(float) var JUMP_VELOCITY = 1000.0
export(float) var RELEASE_GRAVITY_MULTIPLIER = 2.0
export(float) var GROUND_CHECK_DISABLED_DURATION = 0.1

var enter_velocity = Vector2()

var max_horizontal_speed = 0.0
var horizontal_speed = 0.0
var horizontal_velocity = Vector2()

var vertical_speed = 0.0
var height = 0.0

func enter():
	owner.update_velocity_limitations(MAX_VELOCITY, ACCELERATION)
	owner.jump(JUMP_VELOCITY)
	GROUNDED_CHECK.jumping_disable(GROUND_CHECK_DISABLED_DURATION)

func handle_input(event):
	if event.is_action_released("game_jump"):
		if owner.linear_velocity.y < 0:
			owner.update_jump_gravity(RELEASE_GRAVITY_MULTIPLIER)
	return .handle_input(event)

func update(delta):
	owner.set_velocity(get_input_direction())
	if owner.linear_velocity.y >= 0 && owner.gravity_scale != 1.0:
		owner.update_jump_gravity(1.0)
	.update(delta)

func exit():
	owner.update_jump_gravity(1.0)