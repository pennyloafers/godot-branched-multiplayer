extends MultiplayerPeerExtension

class_name ENetMultiplayerPeerExtensionLogger

var enet : = ENetMultiplayerPeer.new()
var peer_type : String = "Unkown"
var logs_enabled : bool = false

func _init() -> void:
	enet.peer_connected.connect(func(id:int):peer_connected.emit(id))
	enet.peer_disconnected.connect(func(id:int):peer_disconnected.emit(id))


### NOTE: MultiplayerPeer 
###

# gdscript only as _put_packet() uses native parameters
func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	print_utl1("put_packet size: %d ", p_buffer.size())
	return enet.put_packet(p_buffer)


# gdscript only as _get_packet() uses native parameters
func _get_packet_script() -> PackedByteArray:
	var packet:PackedByteArray = enet.get_packet()
	print_utl1("get_packet, size: %d", packet.size())
	return packet


func _close() -> void:
	print_utl0("close")
	enet.close()

func _disconnect_peer(p_peer: int, p_force: bool) -> void:
	print_utl2("disconnect_peer %d force %s", p_peer, p_force)
	enet.disconnect_peer(p_peer, p_force)

func _get_available_packet_count() -> int:
	var pc : = enet.get_available_packet_count()
	print_utl1("get_available_packet_count: %d", pc)
	return pc

func _get_connection_status() -> MultiplayerPeer.ConnectionStatus:
	var status:= enet.get_connection_status()
	print_utl1("get_connection_status: %s", get_enum_str(status))
	return status

func _get_max_packet_size() -> int:
	var packet_size : int = enet.get_max_packet_size()
	print_utl1("get_max_packet_size %d ", packet_size)
	return packet_size

func _get_packet_channel() -> int:
	var channel : int = enet.get_packet_channel()
	print_utl1("get_packet_channel: %d ", channel)
	return channel

func _get_packet_mode() -> MultiplayerPeer.TransferMode:
	var mode := enet.get_packet_mode()
	print_utl1("get_packet_mode: %s",get_enum_str(mode))
	return mode

func _get_packet_peer() -> int:
	var peer : int = enet.get_packet_peer()
	print_utl1("get_packet_peer: %d",peer)
	return peer


func _get_transfer_channel() -> int:
	var channel:int = enet.get_transfer_channel()
	print_utl1("get_transfer_channel: %d ", channel)
	return channel

func _get_transfer_mode() -> MultiplayerPeer.TransferMode:
	var mode : = enet.get_packet_mode()
	print_utl1("get_transfer_mode: %s", get_enum_str(mode))
	return mode

func _get_unique_id() -> int:
	var id :int = enet.get_unique_id()
	print_utl1("get_unique_id: %d ", id)
	return id

func _is_refusing_new_connections() -> bool:
	print_utl1("is_refusing_new_connections %s", enet.is_refusing_new_connections())
	return enet.is_refusing_new_connections()

func _is_server() -> bool:
	print_utl1("is_server %s", enet.is_server())
	return enet.is_server()

func _is_server_relay_supported() -> bool:
	print_utl1("is_server_relay_supported %s", enet.is_server_relay_supported())
	return enet.is_server_relay_supported()

func _poll() -> void:
	print_utl0("poll")
	enet.poll()


func _set_refuse_new_connections(p_enable: bool) -> void:
	print_utl1("set_refuse_new_connections %s", p_enable)
	enet.set_refuse_new_connections(p_enable)

func _set_target_peer(p_peer: int) -> void:
	print_utl1("set_target_peer: %d", p_peer)
	enet.set_target_peer(p_peer)

func _set_transfer_channel(p_channel: int) -> void:
	print_utl1("%s: set_transfer_channel: %d", p_channel)
	enet.set_transfer_channel(p_channel)

func _set_transfer_mode(p_mode: MultiplayerPeer.TransferMode) -> void:
	var mode_str : String = get_enum_str(p_mode)
	print_utl1("set_transfer_mode: %s", mode_str)
	enet.set_transfer_mode(p_mode)

### NOTE: ENet functions
###
func add_mesh_peer(peer_id: int, host: ENetConnection) -> Error:
	return enet.add_mesh_peer(peer_id, host)

func create_client(address: String, port: int, channel_count: int = 0, in_bandwidth: int = 0, out_bandwidth: int = 0, local_port: int = 0) -> Error:
	peer_type = "Client"
	var err = enet.create_client(address, port, channel_count, in_bandwidth, out_bandwidth, local_port)
	print_utl1("create_client: %i", err)
	return err

func create_mesh(unique_id: int) -> Error:
	return enet.create_mesh(unique_id)

func create_server(port: int, max_clients: int = 32, max_channels: int = 0, in_bandwidth: int = 0, out_bandwidth: int = 0) -> Error:
	peer_type = "Server"
	var err = enet.create_server(port, max_clients, max_channels, in_bandwidth, out_bandwidth)
	print_utl1("create_server: %i", err)
	return err

func get_peer(id: int) -> ENetPacketPeer:
	return enet.get_peer(id)

func set_bind_ip(ip: String) -> void:
	enet.set_bind_ip(ip)

## NOTE: utility
##
func print_utl0(msg:String):
	if logs_enabled:
		print(peer_type, ": ", msg)

func print_utl1(msg:String, arg:Variant):
	if logs_enabled:
		print(peer_type, ": " , msg % [arg])

func print_utl2(msg:String, arg1:Variant, arg2:Variant):
	if logs_enabled:
		print(peer_type, ": " , msg % [arg1, arg2])

func get_enum_str(value:int) -> String:
	if !logs_enabled:
		return ""
	var value_str : String = ""
	match (value):
		MultiplayerPeer.TransferMode.TRANSFER_MODE_RELIABLE:
			value_str = "TRANSFER_MODE_RELIABLE"
		MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE:
			value_str = "TRANSFER_MODE_UNRELIABLE"
		MultiplayerPeer.TransferMode.TRANSFER_MODE_UNRELIABLE_ORDERED:
			value_str = "TRANSFER_MODE_UNRELIABLE_ORDERED"
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED:
			value_str = "CONNECTION_CONNECTED"
		MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTING:
			value_str = "CONNECTION_CONNECTING"
		MultiplayerPeer.ConnectionStatus.CONNECTION_DISCONNECTED:
			value_str = "CONNECTION_DISCONNECTED"
	return value_str
