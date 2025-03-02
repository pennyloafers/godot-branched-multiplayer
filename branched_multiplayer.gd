extends Node
@export var options : Control
@export var stats_view : Control
@export var view : Control


var view_scene : Control
var synced_scene_res : PackedScene
var server : NetworkPeer
var client : NetworkPeer



func _ready():
	if %SceneOptions.is_split_view():
		create_split_view()
	else:
		create_single_view()


func ping_update(value:int) -> void:
	$%NetStats.ping_update(value)


func create_network_peer(type:int) -> NetworkPeer:
	var peer:NetworkPeer
	if type == NetworkPeer.CLIENT:
		peer = NetworkPeer.create(NetworkPeer.CLIENT)
		peer.ping.connect(ping_update)
	elif type == NetworkPeer.SERVER:
		peer = NetworkPeer.create(NetworkPeer.SERVER)
	peer.set_player_res("res://player/player.tscn")
	peer.new_player.connect(_on_new_player_created, CONNECT_ONE_SHOT)
	return peer

func create_split_view():
	$"%SceneOptions".open_scene_with_current_path()

	# setup networks
	server = create_network_peer(NetworkPeer.SERVER)
	client = create_network_peer(NetworkPeer.CLIENT)

	# setup view
	view_scene = preload("res://scene/split_view.tscn").instantiate()
	view.add_child(view_scene)

	# setup scenes
	view_scene.get_node("%ServerSubViewport").add_child(server)
	view_scene.get_node("%ServerSubViewport").add_child(preload("res://examples/track.tscn").instantiate())
	view_scene.get_node("%ClientSubViewport").add_child(client)
	view_scene.get_node("%ClientSubViewport").add_child(preload("res://examples/track.tscn").instantiate())


func create_single_view():
	$"%SceneOptions".open_scene_with_current_path() # why again?

	# setup networks
	server = create_network_peer(NetworkPeer.SERVER)
	client = create_network_peer(NetworkPeer.CLIENT)
	
	# setup view
	view_scene = preload("res://scene/single_view.tscn").instantiate()
	view.add_child(view_scene)

	# setup scenes
	view_scene.get_node("%SubViewport").add_child(server) 
	view_scene.get_node("%SubViewport").add_child(client)
	view_scene.get_node("%SubViewport").add_child(preload("res://examples/track.tscn").instantiate())

### This works okay, but when using a ring-buffer the physics syncer holds
### stale data. Because recieving syncrhonizer checks packet size errors will
### log if there are delayed packets waiting to be processed.
var reference_synchronizers : Array[Node]
var reference_paths : Array[NodePath]
func _on_new_player_created(player_node:Node) -> void:
	# filter for owner of node and add to ui
	var synchronizers = find_synchronizers(player_node)
	var filtered_synchronizers = synchronizers.filter( func (syncer): return syncer.get_multiplayer_authority() == player_node.multiplayer.get_unique_id())
	for syncer:MultiplayerSynchronizer in filtered_synchronizers :
		$"%ReplicationOptions".parse_syncer(syncer, player_node.get_path_to(syncer))
	
	if reference_synchronizers.is_empty():
		# setup for shared replication configs
		reference_synchronizers = synchronizers
		for syncer:MultiplayerSynchronizer in reference_synchronizers :
			reference_paths.append(player_node.get_path_to(syncer))
	else:
		# share replications configs, need to match syncer to syncer.
		for syncer:MultiplayerSynchronizer in synchronizers:
			var path:NodePath = player_node.get_path_to(syncer) 
			for i:int in reference_synchronizers.size():
				if syncer.name == reference_synchronizers[i].name and path == reference_paths[i]:
					syncer.replication_config = reference_synchronizers[i].replication_config
	

func reset() -> void:
	$"%ReplicationOptions".reset()
	# remove references but dont manually free nodes
	reference_synchronizers.clear()
	reference_paths.clear()

	if view_scene:
		view.remove_child(view_scene)
		view_scene.queue_free()
		view_scene = null
		server = null
		client = null
		if %SceneOptions.is_split_view():
			create_split_view()
		else:
			create_single_view()

func _on_reset_pressed() -> void:
	reset()

func _on_scene_options_split_view_change(_split_view: bool) -> void:
	reset()


func _on_scene_options_scene_selected(path: String) -> void:
	reset()
	synced_scene_res = load(path)

func find_synchronizers(scene:Node )->Array[Node]:
	return scene.find_children("*","MultiplayerSynchronizer")


func _on_network_options_frame_delay(value: int) -> void:
	server.enet.network_frame_delay = value
	client.enet.network_frame_delay = value


func _on_network_options_jitter_enabled(value: bool) -> void:
	server.enet.jitter_enabled = value
	client.enet.jitter_enabled = value


func _on_network_options_jitter_chance(value: float) -> void:
	server.enet.jitter_chance = value
	client.enet.jitter_chance = value


func _on_network_options_jitter_range( min_value: int, max_value: int) -> void:
	server.enet.jitter_min = min_value
	server.enet.jitter_max = max_value
	client.enet.jitter_min = min_value
	client.enet.jitter_max = max_value
