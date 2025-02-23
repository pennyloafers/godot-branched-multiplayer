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
var player_res : PackedScene
var player_instance : Node
signal new_player(player_node:Node)

enum {
	SERVER,
	CLIENT,
	NONE
}
var network_type :int = NONE
func _init(type:int = NONE):
	network_type = type

#var enet := ENetMultiplayerPeer.new()
var enet := ENetMultiplayerPeerExtension.new()
func _ready() -> void:
	var api := SceneMultiplayer.new()
	#api.set_auth_callback(auth_callback)
	match network_type:
		SERVER:
			enet.create_server(PORT)
			self.name = "server"
			api.peer_connected.connect(_on_peer_connected)
			api.peer_authenticating.connect(_on_peer_authenticating)
		CLIENT:
			client_count += 1
			enet.create_client(IP_ADDR, PORT)
			self.name = "client" + str(client_count) 
			api.connected_to_server.connect(_on_connected_to_server)
		_:
			printerr("Invalid Network Type")
			return
	api.multiplayer_peer = enet
	player_spawner.spawn_function = spawn_func
	get_tree().set_multiplayer(api, self.get_path())

func set_player_node(path:String) -> void:
	player_res = load(path)
	#NOTE: custom spawn makes spawning the node work without adding it to the scene list. are there problems with that?
	#if player_res:
		#print(name,": adding scene ", path)
		#player_spawner.add_spawnable_scene(path) #TODO: if I need to use this, player spawner isn't ready yet

func _on_connected_to_server():
	print("server_connected")
	var node = Node.new()
	node.name = "id_" + str(multiplayer.get_unique_id())
	add_child(node)


func _on_peer_connected(id):
	print("peer_connected: ", id)
	if player_res:
		player_spawner.spawn(id)
	else:
		printerr("Player resource was not set")

func spawn_func(id:int):
	var p = player_res.instantiate()
	p.name = str(id)
	p.ready.connect(_on_player_ready, CONNECT_DEFERRED)
	player_instance = p
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
	print("peer_authenticating: ", id)
	multiplayer.send_auth(id, "hello".to_ascii_buffer())

func _exit_tree() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null


func _on_player_ready() -> void:
	new_player.emit(player_instance)
