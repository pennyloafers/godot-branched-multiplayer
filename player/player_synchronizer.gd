class_name PhysicsSynchronizer
extends MultiplayerSynchronizer

@export var sync_object : RigidBody3D
@onready var body_state : PhysicsDirectBodyState3D = \
	PhysicsServer3D.body_get_direct_state( sync_object.get_rid() )
@export_storage var sync_pos   : Vector3
@export_storage var sync_lvel  : Vector3
@export_storage var sync_avel  : Vector3
@export_storage var sync_quat  : Quaternion = Quaternion.IDENTITY
@export_storage var sync_frame : int = 0

@export var temp_hide : bool = false
var ring_buffer:RingBuffer = RingBuffer.new()

var last_frame = -1
var set_num = 0

enum {
	ORIGIN,
	LIN_VEL,
	ANG_VEL,
	QUAT, # the quaternion is used for an optimized rotation state
}

func _init() -> void:
	replication_config = SceneReplicationConfig.new()
	replication_config.add_property(^".:sync_pos")
	replication_config.add_property(^".:sync_lvel")
	replication_config.add_property(^".:sync_avel")
	replication_config.add_property(^".:sync_quat")
	replication_config.add_property(^".:sync_frame")
	for property in replication_config.get_properties():
		replication_config.property_set_replication_mode(property, SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
		replication_config.property_set_spawn(property, true)


func _ready():
	if is_multiplayer_authority():
		sync_object.sleeping_state_changed.connect(_on_sleeping_state_changed)
	elif temp_hide:
		sync_object.hide()
		get_tree().create_timer(get_physics_process_delta_time()*4).timeout.connect(func(): sync_object.show())
	self.synchronized.connect(_on_synchronized)


func _exit_tree():
	ring_buffer.free()

func _on_sleeping_state_changed():
	if sync_object.sleeping:
		print(sync_object.name, ": sleeping")
		replication_interval = get_physics_process_delta_time() * 8.0
	else:
		replication_interval = 0.0

#copy state to array
func get_state(state : PhysicsDirectBodyState3D ):
	sync_pos = state.transform.origin
	sync_quat = state.transform.basis.get_rotation_quaternion()
	sync_lvel = state.linear_velocity
	sync_avel = state.angular_velocity


#copy array to state
func set_state(state : PhysicsDirectBodyState3D, data:Array ):
	state.transform.origin = data[ORIGIN]
	state.linear_velocity = data[LIN_VEL]
	state.angular_velocity = data[ANG_VEL]
	state.transform.basis = Basis(data[QUAT])


func get_physics_body_info():
	# server copy for sync
	get_state( body_state )


func set_physics_body_info():
	# client rpc set from server
	var data :Array = ring_buffer.remove()
	while data.is_empty():
		return
	set_state( body_state, data )


func _physics_process(_delta):
	if is_multiplayer_authority():
		sync_frame += 1
		get_physics_body_info()
	else:
		set_physics_body_info()


# make sure to wire the "synchronized" signal to this function
func _on_synchronized():
	if is_previouse_frame():
		return
	ring_buffer.add([
		sync_pos,
		sync_lvel,
		sync_avel,
		sync_quat,
	])


func is_previouse_frame() -> bool:
	if sync_frame <= last_frame:
		#print("previous frame %d %d" % [sync_frame, last_frame] )
		return true
	else:
		last_frame = sync_frame
		return false

class RingBuffer extends Object:
	const SAFETY:int = 1
	const CAPACITY:int = 1 + SAFETY
	var buf:Array[Array]
	var head:int = 0
	var tail:int = 0

	func _init():
		buf.resize(CAPACITY)
		for i in CAPACITY:
			buf[i] = []
		head = CAPACITY - SAFETY

	func add(frame:Array):
		if _increment(head) == tail: # full
			print("physics syncer drop")
			remove() #drop frame
		buf[head]=frame
		head = _increment(head)

	func _increment(index:int)->int:
		index += 1
		if index == CAPACITY: # avoid modulus
			index = 0
		return index

	func remove() -> Array:
		var frame : Array = buf[tail]
		if is_empty():
			frame = []
		else:
			tail = _increment(tail)
		return frame

	func is_empty() -> bool:
		return tail == head
