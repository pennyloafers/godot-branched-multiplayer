extends RigidBody3D
class_name Player

static func create() -> Player:
	return preload("res://player/player.tscn").instantiate()

@onready var grid = $GridContainer
@onready var speed_label = $GridContainer/SpeedValue
@onready var pressed_label = $GridContainer/PressedValue
@onready var mesh = $MeshInstance3D
@onready var position_value: Label = $GridContainer/PositionValue
@onready var peer: Label = $GridContainer/Peer


@export var move : bool = false
var press: float = 1.0 #seconds
var release: float = 3.0 #seconds

signal simulated_input(pressed:int)


func _ready() -> void:
	if multiplayer.is_server():
		grid.set_anchors_preset(Control.PRESET_CENTER_TOP,true)
		speed_label.label_settings.outline_color = Color.RED
		pressed_label.label_settings.outline_color = Color.RED
		mesh.mesh.material.set_shader_parameter("albedo",Color.RED)
		$Arm/Camera3D.current = true
		peer.text = "Server"
		collision_layer = 2
		collision_mask = 2
	else:
		simulated_input.connect(input_routine)
		simulated_input.emit(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_up"):
		#print(name," pressed ", event.is_pressed())
		move = event.is_pressed()

func _physics_process(_delta: float) -> void:
	var x = Vector3.ZERO
	x.x -= global_position.x
	apply_central_force( x * 1) #center
	apply_central_force(Vector3.MODEL_FRONT * int(move) * 4) #forward
	apply_torque(Vector3.UP  * int(move))
	set_labels()

func set_labels():
	speed_label.text = "%.2f" % linear_velocity.length()
	pressed_label.text = str(move)
	position_value.text = str(global_position)
	

func input_routine(pressed:int):
	_simulate_input(pressed)
	var wait_time = press if pressed else release
	await get_tree().create_timer(wait_time).timeout
	simulated_input.emit(!pressed)

func _simulate_input(pressed:bool):
	var event = InputEventAction.new()
	event.action = "ui_up"
	event.pressed = pressed
	_unhandled_input(event)


func _on_rpcbutton_pressed() -> void:
	my_rpc.rpc("hello")

@rpc("any_peer","call_remote","reliable")
func my_rpc(text:String):
	var who:String = "Client"
	if multiplayer.is_server():
		who = "Server"
	print("%s recieved %s" % [who, text])
	print()
