extends MultiplayerPeerExtension

class_name ENetMultiplayerPeerExtensionPassthrough

var enet : = ENetMultiplayerPeer.new()
var peer_type : String = "Unkown"

func _init() -> void:
	enet.peer_connected.connect(func(id:int):peer_connected.emit(id))
	enet.peer_disconnected.connect(func(id:int):peer_disconnected.emit(id))


### NOTE: MultiplayerPeer 
###

func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	return enet.put_packet(p_buffer)

# gdscript only as _get_packet() uses native parameters
func _get_packet_script() -> PackedByteArray:
	return enet.get_packet()

func _close() -> void:
	enet.close()

func _disconnect_peer(p_peer: int, p_force: bool) -> void:
	enet.disconnect_peer(p_peer, p_force)

func _get_available_packet_count() -> int:
	return enet.get_available_packet_count()

func _get_connection_status() -> MultiplayerPeer.ConnectionStatus:
	return enet.get_connection_status()

func _get_max_packet_size() -> int:
	return enet.get_max_packet_size()

func _get_packet_channel() -> int:
	return enet.get_packet_channel()

func _get_packet_mode() -> MultiplayerPeer.TransferMode:
	return enet.get_packet_mode()

func _get_packet_peer() -> int:
	return enet.get_packet_peer()

func _get_transfer_channel() -> int:
	return enet.get_transfer_channel()

func _get_transfer_mode() -> MultiplayerPeer.TransferMode:
	return enet.get_packet_mode()

func _get_unique_id() -> int:
	return enet.get_unique_id()

func _is_refusing_new_connections() -> bool:
	return enet.is_refusing_new_connections()

func _is_server() -> bool:
	return enet.is_server()

func _is_server_relay_supported() -> bool:
	return enet.is_server_relay_supported()

func _poll() -> void:
	enet.poll()


func _set_refuse_new_connections(p_enable: bool) -> void:
	enet.set_refuse_new_connections(p_enable)

func _set_target_peer(p_peer: int) -> void:
	enet.set_target_peer(p_peer)

func _set_transfer_channel(p_channel: int) -> void:
	enet.set_transfer_channel(p_channel)

func _set_transfer_mode(p_mode: MultiplayerPeer.TransferMode) -> void:
	enet.set_transfer_mode(p_mode)

### NOTE: ENet functions
###
func add_mesh_peer(peer_id: int, host: ENetConnection) -> Error:
	return enet.add_mesh_peer(peer_id, host)

func create_client(address: String, port: int, channel_count: int = 0, in_bandwidth: int = 0, out_bandwidth: int = 0, local_port: int = 0) -> Error:
	peer_type = "Client"
	return enet.create_client(address, port, channel_count, in_bandwidth, out_bandwidth, local_port)

func create_mesh(unique_id: int) -> Error:
	return enet.create_mesh(unique_id)

func create_server(port: int, max_clients: int = 32, max_channels: int = 0, in_bandwidth: int = 0, out_bandwidth: int = 0) -> Error:
	peer_type = "Server"
	return enet.create_server(port, max_clients, max_channels, in_bandwidth, out_bandwidth)


func get_peer(id: int) -> ENetPacketPeer:
	return enet.get_peer(id)

func set_bind_ip(ip: String) -> void:
	enet.set_bind_ip(ip)
