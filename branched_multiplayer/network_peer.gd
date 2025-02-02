extends Node

class_name NetworkPeer
static func create(type:int) -> NetworkPeer:
	var peer : NetworkPeer = preload("res://branched_multiplayer/network_peer.tscn").instantiate(type) as NetworkPeer
	peer.network_type = type
	return peer

static var client_count : int = 0

const IP_ADDR := "localhost"
const PORT := 5555

@onready var player_spawner : MultiplayerSpawner = $PlayerSpawner 

enum {
	SERVER,
	CLIENT,
	NONE
}
var network_type :int = NONE
func _init(type:int = NONE):
	network_type = type

func _ready() -> void:
	var enet := ENetMultiplayerPeer.new()
	var api := MyMultiplayer.new()
	match network_type:
		SERVER:
			api.set_auth_callback(auth_callback)
			enet.create_server(PORT)
			api.multiplayer_peer = enet
			self.name = "server"
			api.peer_connected.connect(_on_peer_connected)
			api.get_peer_authenticating_signal().connect(_on_peer_authenticating)
		CLIENT:
			client_count += 1
			api.set_auth_callback(auth_callback)
			enet.create_client(IP_ADDR, PORT)
			api.multiplayer_peer = enet
			self.name = "client" + str(client_count) 
			api.connected_to_server.connect(_on_connected_to_server)
		_:
			printerr("Invalid Network Type")
			return
	player_spawner.spawn_function = spawn_func
	get_tree().set_multiplayer(api, self.get_path())

func _on_connected_to_server():
	print("server_connected")
	var node = Node.new()
	node.name = "id_" + str(multiplayer.get_unique_id())
	add_child(node)


func _on_peer_connected(id):
	print("peer_connected")
	player_spawner.spawn(id)

func spawn_func(id:int):
	var p = Player.create()
	p.name = str(id)
	return p

func auth_callback(id:int, data:PackedByteArray):
	print("auth ", multiplayer.get_unique_id())
	print(data.get_string_from_ascii())
	if not multiplayer.is_server():
		multiplayer.send_auth(id, "auth_me".to_ascii_buffer())
		multiplayer.complete_auth(id)
	else:
		if data.get_string_from_ascii() == "auth_me":
			print("auth complete")
			multiplayer.complete_auth(id)
			

func _on_peer_authenticating(id):
	print("peer_authenticating")
	multiplayer.send_auth(id, "hello".to_ascii_buffer())
