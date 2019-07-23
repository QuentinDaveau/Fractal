extends Position2D

export(bool) var enabled = true
export(NodePath) var targetPath
export(NodePath) var referencePath
onready var target = get_node(targetPath)
#onready var reference = get_node(referencePath)
var appliedForce = Vector2(0.0, 0.0)


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
