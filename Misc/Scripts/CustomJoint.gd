extends Position2D

export(NodePath) var node_a_path: NodePath
export(NodePath) var node_b_path: NodePath

export(Vector2) var node_a_offset: Vector2 = Vector2(0.0, 0.0)
export(Vector2) var node_b_offset: Vector2 = Vector2(0.0, 0.0)

export(float, 0, 0.9, 0.1) var biais: float
export(bool) var lock_rotation: bool = false
export(float, 0, 360) var lock_angle: float = 0.0

onready var _node_a: PhysicsBody2D = get_node(node_a_path)
onready var _node_b: PhysicsBody2D = get_node(node_b_path)

func _physics_process(delta):
	_node_a.phys
