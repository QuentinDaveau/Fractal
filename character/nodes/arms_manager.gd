extends Node

signal state_changed(current_state)
export(String, "idle", "aiming", "stagger") var START_STATE: String = "idle"

onready var DEAD_ZONE: float = owner.get_property("DEAD_ZONE")
onready var RIGHT_ARM_AXLE: Position2D = owner.get_node("Ghost/TorsoAxle/TorsoArmAxle")
onready var LEFT_ARM_AXLE: Position2D = owner.get_node("Ghost/TorsoAxle/TorsoArmAxle2")

var states_map = ["idle", "aiming", "stagger"]
var states_stack = []
var current_state = null
var _active = false setget set_active

var _device_id: int
var _input_direction: Vector2

func _ready():
	owner.connect("device_set", self, "_set_device")
	initialize(START_STATE)

func _unhandled_input(event):
	if event.device == _device_id:
		match current_state:
			"idle":
				_update_input_direction(event)
				if _input_direction:
					_change_state("aiming")
					return
			"aiming":
				_update_input_direction(event)
				if not _input_direction:
					_change_state("idle")
					return
				_update_arms_direction(_input_direction)
			"stagger":
				return

func initialize(start_state):
	set_active(true)
	states_stack.push_front(start_state)
	current_state = states_stack[0]
	_enter_current_state()

func set_active(value):
	_active = value
	set_physics_process(value)
	set_process_input(value)
	if not _active:
		states_stack = []
		current_state = null

func _set_device(device_id):
	_device_id = device_id

func _change_state(state_name):
	if not _active:
		return
	_exit_current_state()
	
	if not state_name in states_map:
		print("Uknown arms state")
		return
	
	if state_name == "previous":
		states_stack.pop_front()
	else:
		states_stack[0] = state_name
	
	current_state = states_stack[0]
	
	emit_signal("state_changed", current_state)
	
	print(current_state)
	
	_enter_current_state()

func _exit_current_state() -> void:
	match current_state:
		"idle":
			return
		"aiming":
			return
		"stagger":
			return

func _enter_current_state() -> void:
	match current_state:
		"idle":
			_update_arms_direction(Vector2(0, 1))
		"aiming":
			return
		"stagger":
			return

func _update_input_direction(event) -> void:
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) < DEAD_ZONE:
			event.axis_value = 0.0
		if event.axis == 2:
			_input_direction.x = event.axis_value
		if event.axis == 3:
			_input_direction.y = event.axis_value

func _update_arms_direction(direction) -> void:
	RIGHT_ARM_AXLE.rotation = direction.angle() - (PI/2)
	LEFT_ARM_AXLE.rotation = direction.angle() - (PI/2)