extends "../motion.gd"

var speed = 0.0
var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump"):
		emit_signal("finished", "jump")
	
	# Add if on_ground check and small delay
	
	return .handle_input(event)