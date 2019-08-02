extends Node

export(NodePath) var RIGHT_SHOULDER_PATH
export(NodePath) var LEFT_SHOULDER_PATH

onready var ghost_arms_axles: Dictionary = {
	"right_shoulder": get_node(RIGHT_SHOULDER_PATH),
	"right_elbow": get_node(str(RIGHT_SHOULDER_PATH) + "/ElbowAxle"),
	"right_hand": get_node(str(RIGHT_SHOULDER_PATH) + "/ElbowAxle/Hand"),
	"left_shoulder": get_node(LEFT_SHOULDER_PATH),
	"left_elbow": get_node(str(LEFT_SHOULDER_PATH) + "/ElbowAxle2"),
	"left_hand": get_node(str(LEFT_SHOULDER_PATH) + "/ElbowAxle2/Hand2")}

func set_positions(handles_positions: Array) -> void:
	
	print(handles_positions, handles_positions[0].length())
	
	var right_angles = _find_angles(ghost_arms_axles.right_elbow.position.length(),
	 ghost_arms_axles.right_hand.position.length(),
	 (handles_positions[0]).length())
	
	var left_angles = _find_angles(ghost_arms_axles.left_elbow.position.length(),
	 ghost_arms_axles.left_hand.position.length(),
	 (handles_positions[1]).length())
	
	ghost_arms_axles.right_shoulder.rotation = right_angles[0] + handles_positions[0].angle() - PI/2
	ghost_arms_axles.right_elbow.rotation = - PI + right_angles[1]
	
	ghost_arms_axles.left_shoulder.rotation = left_angles[0] + handles_positions[1].angle() - PI/2
	ghost_arms_axles.left_elbow.rotation = - PI + left_angles[1]
	

func _find_angles(length1, length2, distance) -> Array:
	print(length1, "   ", length2, "   ", distance, "     ")
	if abs(length1 - length2) > distance || length1 + length2 < distance:
		return [0, 0]
	var angle1 = acos((pow(length1, 2) + pow(distance, 2) - pow(length2, 2)) / (2 * length1 * distance))
	var angle2 = acos((pow(length1, 2) + pow(length2, 2) - pow(distance, 2)) / (2 * length1 * length2))
	print(angle1, "    ", angle2)
	return [angle1, angle2]