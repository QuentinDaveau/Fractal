extends RigidBody2D

export(float) var power = 0.1

onready var raycast = $ReferencePoint/RayCast2D

var ghostOffset = 0.0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	$BodyParts/ArmTop.add_collision_exception_with($BodyParts/ArmTop2)
	$BodyParts/ArmTop2.add_collision_exception_with($BodyParts/ArmTop)
	$BodyParts/LegTop.add_collision_exception_with($BodyParts/LegTop2)
	$BodyParts/LegTop2.add_collision_exception_with($BodyParts/LegTop)
	$BodyParts/ArmTop.add_collision_exception_with($BodyParts/ArmTop2/ArmBottom2)
	$BodyParts/ArmTop2.add_collision_exception_with($BodyParts/ArmTop/ArmBottom)
	$BodyParts/LegTop.add_collision_exception_with($BodyParts/LegTop2/LegBottom2)
	$BodyParts/LegTop2.add_collision_exception_with($BodyParts/LegTop/LegBottom)

	$BodyParts/ArmTop/ArmBottom.add_collision_exception_with($BodyParts/ArmTop2)
	$BodyParts/ArmTop2/ArmBottom2.add_collision_exception_with($BodyParts/ArmTop)
	$BodyParts/LegTop/LegBottom.add_collision_exception_with($BodyParts/LegTop2)
	$BodyParts/LegTop2/LegBottom2.add_collision_exception_with($BodyParts/LegTop)
	$BodyParts/ArmTop/ArmBottom.add_collision_exception_with($BodyParts/ArmTop2/ArmBottom2)
	$BodyParts/ArmTop2/ArmBottom2.add_collision_exception_with($BodyParts/ArmTop/ArmBottom)
	$BodyParts/LegTop/LegBottom.add_collision_exception_with($BodyParts/LegTop2/LegBottom2)
	$BodyParts/LegTop2/LegBottom2.add_collision_exception_with($BodyParts/LegTop/LegBottom)

	$BodyParts/ArmTop/ArmBottom.add_collision_exception_with(self)
	$BodyParts/ArmTop2/ArmBottom2.add_collision_exception_with(self)

	$BodyParts/ArmTop.add_collision_exception_with($BodyParts/Head)
	$BodyParts/ArmTop2.add_collision_exception_with($BodyParts/Head)
	$BodyParts/ArmTop/ArmBottom.add_collision_exception_with($BodyParts/Head)
	$BodyParts/ArmTop2/ArmBottom2.add_collision_exception_with($BodyParts/Head)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _physics_process(delta):
	
	$ReferencePoint.global_rotation = 0.0
	$Ghost.global_rotation = 0.0
	
	if(raycast.is_colliding()):
		
		$Ghost.global_position = global_position + (raycast.global_position.y - raycast.get_collision_point().y)
	

