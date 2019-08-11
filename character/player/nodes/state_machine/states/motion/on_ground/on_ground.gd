extends "../motion.gd"

export(NodePath) var GROUNDED_CHECK_PATH

export(float) var MAX_VELOCITY = 450.0
export(float) var ACCELERATION = 1000.0

onready var GROUNDED_CHECK = get_node(GROUNDED_CHECK_PATH)

func handle_input(event):
	if event.is_action_pressed("game_jump"):
		if GROUNDED_CHECK.is_grounded():
			emit_signal("finished", "jump")
	
	return .handle_input(event)

func update(delta):
	if not GROUNDED_CHECK.is_grounded():
		emit_signal("finished", "fall")