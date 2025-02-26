# GdUnit generated TestSuite
class_name NetworkPeerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://multiplayer/network_peer.gd'


func test_network() -> void:
	var server := NetworkPeer.create(NetworkPeer.SERVER)
	var client := NetworkPeer.create(NetworkPeer.CLIENT)
	# server.set_process(false)
	# client.set_process(false)
	#ready
	add_child(server)
	add_child(client)
	await server.multiplayer.peer_connected
	print("peer connected")
	
	client.request_server_rtt()
	assert_signal(client).is_emitted("ping")
	
	
	
	# server.queue_free()
	# client.queue_free()
	
	
	
	
	
