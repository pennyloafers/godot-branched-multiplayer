extends Node

class_name Main
static var instance : Main
static func set_instance(inst:Main):
	instance = inst

static func get_instance() -> Main:
	if instance:
		return instance
	else:
		assert(true)
		return

const PEERS : int = 2

var client_side_input : bool = false
var pos_sync:bool = true
var vel_sync:bool = false
var ang_vel_sync:bool = false
var rotation_sync:bool = false
var replication_time :float = 0.2

func _init() -> void:
	set_instance(self)

func _ready():
	for peer in PEERS:
		var peer_node : NetworkPeer 
		if peer == 0:
			peer_node = NetworkPeer.create(NetworkPeer.SERVER)
		else:
			peer_node = NetworkPeer.create(NetworkPeer.CLIENT)
		add_child(peer_node)


func _on_client_side_input_toggled(toggled_on: bool) -> void:
	client_side_input = toggled_on


func _on_postion_sync_toggled(toggled_on: bool) -> void:
	pos_sync = toggled_on

func _on_linear_vel_sync_toggled(toggled_on: bool) -> void:
	vel_sync = toggled_on

func _on_angular_vel_sync_toggled(toggled_on: bool) -> void:
	ang_vel_sync = toggled_on


func _on_rotation_sync_toggled(toggled_on: bool) -> void:
	rotation_sync = toggled_on


func _on_replication_interval_value_changed(value: float) -> void:
	replication_time = value
