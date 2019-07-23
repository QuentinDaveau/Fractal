extends Node



func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here

	$ArmTop.add_collision_exception_with($ArmTop2)
	$ArmTop2.add_collision_exception_with($ArmTop)
	$LegTop.add_collision_exception_with($LegTop2)
	$LegTop2.add_collision_exception_with($LegTop)
	$ArmTop.add_collision_exception_with($ArmTop2/ArmBottom2)
	$ArmTop2.add_collision_exception_with($ArmTop/ArmBottom)
	$LegTop.add_collision_exception_with($LegTop2/LegBottom2)
	$LegTop2.add_collision_exception_with($LegTop/LegBottom)

	$ArmTop/ArmBottom.add_collision_exception_with($ArmTop2)
	$ArmTop2/ArmBottom2.add_collision_exception_with($ArmTop)
	$LegTop/LegBottom.add_collision_exception_with($LegTop2)
	$LegTop2/LegBottom2.add_collision_exception_with($LegTop)
	$ArmTop/ArmBottom.add_collision_exception_with($ArmTop2/ArmBottom2)
	$ArmTop2/ArmBottom2.add_collision_exception_with($ArmTop/ArmBottom)
	$LegTop/LegBottom.add_collision_exception_with($LegTop2/LegBottom2)
	$LegTop2/LegBottom2.add_collision_exception_with($LegTop/LegBottom)

	$ArmTop/ArmBottom.add_collision_exception_with($Torso)
	$ArmTop2/ArmBottom2.add_collision_exception_with($Torso)

	$ArmTop.add_collision_exception_with($Head)
	$ArmTop2.add_collision_exception_with($Head)
	$ArmTop/ArmBottom.add_collision_exception_with($Head)
	$ArmTop2/ArmBottom2.add_collision_exception_with($Head)

	$LegTop.add_collision_exception_with($Head)
	$LegTop2.add_collision_exception_with($Head)
	$LegTop/LegBottom.add_collision_exception_with($Head)
	$LegTop2/LegBottom2.add_collision_exception_with($Head)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

