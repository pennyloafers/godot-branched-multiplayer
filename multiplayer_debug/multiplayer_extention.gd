extends MultiplayerAPIExtension
class_name MyMultiplayer

# We want to augment the default SceneMultiplayer.
var base_multiplayer = SceneMultiplayer.new()

func _init():
	# Just passthrough base signals (copied to var to avoid cyclic reference)
	var cts = connected_to_server
	var cf = connection_failed
	var pc = peer_connected
	var pd = peer_disconnected
	base_multiplayer.connected_to_server.connect(func(): cts.emit())
	base_multiplayer.connection_failed.connect(func(): cf.emit())
	base_multiplayer.peer_connected.connect(func(id): pc.emit(id))
	base_multiplayer.peer_disconnected.connect(func(id): pd.emit(id))

func _poll():
	return base_multiplayer.poll()

# Log RPC being made and forward it to the default multiplayer.
func _rpc(peer: int, object: Object, method: StringName, args: Array) -> Error:
	var who := "Client"
	if is_server():
		who = "Server"
	print("%s: Got RPC for %d: %s::%s(%s)" % [who, peer, object, method, args])
	return base_multiplayer.rpc(peer, object, method, args)

# Log configuration add. E.g. root path (nullptr, NodePath), replication (Node, Spawner|Synchronizer), custom.
func _object_configuration_add(object, config: Variant) -> Error:
	var who := "Client"
	if is_server():
		who = "Server"
	if config is MultiplayerSynchronizer:
		print("%s: Adding synchronization configuration for %s. Synchronizer: %s" % [who, object.name, config])
	elif config is MultiplayerSpawner:
		print("%s: Adding node %s to the spawn list. Spawner: %s" % [who, object.name, config])
	return base_multiplayer.object_configuration_add(object, config)

# Log configuration remove. E.g. root path (nullptr, NodePath), replication (Node, Spawner|Synchronizer), custom.
func _object_configuration_remove(object, config: Variant) -> Error:
	var who := "Client"
	if is_server():
		who = "Server"
	if config is MultiplayerSynchronizer:
		print("%s: Removing synchronization configuration for %s. Synchronizer: %s" % [who, object.name, config])
	elif config is MultiplayerSpawner:
		print("%s: Removing node %s from the spawn list. Spawner: %s" % [who, object, config])
	return base_multiplayer.object_configuration_remove(object, config)

# These can be optional, but in our case we want to augment SceneMultiplayer, so forward everything.
func _set_multiplayer_peer(p_peer: MultiplayerPeer):
	base_multiplayer.multiplayer_peer = p_peer

func _get_multiplayer_peer() -> MultiplayerPeer:
	return base_multiplayer.multiplayer_peer

func _get_unique_id() -> int:
	return base_multiplayer.get_unique_id()

func _get_peer_ids() -> PackedInt32Array:
	return base_multiplayer.get_peers()

func set_auth_callback(cb:Callable):
	base_multiplayer.auth_callback = cb

func get_peer_authenticating_signal()->Signal:
	return base_multiplayer.peer_authenticating

func send_auth(id:int, data:PackedByteArray):
	base_multiplayer.send_auth(id, data)

func complete_auth(id:int):
	base_multiplayer.complete_auth(id)
