extends RigidBody2D

export(float) var power = 200

onready var raycast = $ReferencePoint/RayCast2D

var ghostOffset = 0.0

onready var armTop = $BodyParts/ArmTop
onready var armBot = $BodyParts/ArmTop/ArmBottom

onready var armTop2 = $BodyParts/ArmTop2
onready var armBot2 = $BodyParts/ArmTop2/ArmBottom2

onready var legTop = $BodyParts/LegTop
onready var legBot = $BodyParts/LegTop/LegBottom

onready var legTop2 = $BodyParts/LegTop2
onready var legBot2 = $BodyParts/LegTop2/LegBottom2

onready var head = $BodyParts/Head

onready var bodyPartsDict = {self:[$TorsoTopAnchor, $TorsoBottomAnchor]}
var drawList = []

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	getallnodes($BodyParts)
	print(bodyPartsDict)
	
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
	
	$BodyParts/ArmTop/ArmBottom.add_collision_exception_with($BodyParts/LegTop)
	$BodyParts/ArmTop/ArmBottom.add_collision_exception_with($BodyParts/LegTop2)
	$BodyParts/ArmTop2/ArmBottom2.add_collision_exception_with($BodyParts/LegTop)
	$BodyParts/ArmTop2/ArmBottom2.add_collision_exception_with($BodyParts/LegTop2)

	$BodyParts/ArmTop.add_collision_exception_with($BodyParts/Head)
	$BodyParts/ArmTop2.add_collision_exception_with($BodyParts/Head)
	$BodyParts/ArmTop/ArmBottom.add_collision_exception_with($BodyParts/Head)
	$BodyParts/ArmTop2/ArmBottom2.add_collision_exception_with($BodyParts/Head)
	
#	$BodyParts/Head.apply_impulse($BodyParts/Head/HeadAnchor.global_position,Vector2(10.0, 0))
	
	pass

func getallnodes(node):
	for N in node.get_children():
		if N.is_class("RigidBody2D"):
			if N.get_child_count() > 0:
				print("["+N.get_name()+"]")
				var anchor = N.find_node("*Anchor")
				if(anchor.enabled):
					bodyPartsDict[N] = [anchor]
				getallnodes(N)
			else:
				# Do something
				print("- "+N.get_name())
				var anchor = N.find_node("*Anchor")
				if(anchor.enabled):
					bodyPartsDict[N] = [anchor]

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _physics_process(delta):
	
	drawList = []
	
	$ReferencePoint.global_rotation = 0.0
	$Ghost.global_rotation = 0.0
	$Ghost.global_position = global_position
	
	if(raycast.is_colliding()):
		
		$Ghost.global_position.y = global_position.y - (raycast.cast_to.y + (raycast.global_position.y - raycast.get_collision_point().y))
	
	for key in bodyPartsDict:

		for value in bodyPartsDict[key]:

			_impulse_to_reach(key, value)
	
	update()
	
#	_impulse_to_reach($BodyParts/Head, $BodyParts/Head/HeadAnchor, $Ghost.get_target("Head"))
#
#	_impulse_to_reach(self, $TorsoTopAnchor, $Ghost.get_target("TorsoTop"))
#	_impulse_to_reach(self, $TorsoBottomAnchor, $Ghost.get_target("TorsoBot"))
#
#	_impulse_to_reach($BodyParts/Head, $BodyParts/Head/HeadAnchor, $Ghost.get_target("Head"))
#	_impulse_to_reach($BodyParts/Head, $BodyParts/Head/HeadAnchor, $Ghost.get_target("Head"))
#
#	_impulse_to_reach($BodyParts/Head, $BodyParts/Head/HeadAnchor, $Ghost.get_target("Head"))
#	_impulse_to_reach($BodyParts/Head, $BodyParts/Head/HeadAnchor, $Ghost.get_target("Head"))
#
#	_impulse_to_reach($BodyParts/Head, $BodyParts/Head/HeadAnchor, $Ghost.get_target("Head"))
#	_impulse_to_reach($BodyParts/Head, $BodyParts/Head/HeadAnchor, $Ghost.get_target("Head"))

func _impulse_to_reach(body, anchor):
	
	
	body.add_force(anchor.position, -anchor.appliedForce)
	
	var appliedForce = (anchor.target.global_position - anchor.global_position) * (anchor.target.global_position - anchor.global_position).abs() * power
	anchor.appliedForce = appliedForce

	drawList.append([anchor.position, anchor.position + appliedForce])
#	print(anchor.appliedForce)
#	print(anchor.position)
	body.add_force(anchor.position, appliedForce)

func _draw():
	
	for element in drawList:
	
		draw_line(element[0], element[1], Color(255, 0, 0))