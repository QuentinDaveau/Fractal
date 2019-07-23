extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var reference = $Body/Torso/ReferencePoint

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _physics_process(delta):

	position += Vector2(10, 0.0)