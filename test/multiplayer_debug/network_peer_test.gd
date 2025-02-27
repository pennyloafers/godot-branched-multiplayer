# GdUnit generated TestSuite
class_name NetworkPeerTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://multiplayer/network_peer.gd'

func await_frames(number:int):
	for _i in number:
		await await_idle_frame()

func await_poll_peer(number:int, peer:ENetMultiplayerPeerExtension):
	for _i in number:
		await await_idle_frame()
		peer.poll()

func await_poll(number:int, server:ENetMultiplayerPeerExtension, client:ENetMultiplayerPeerExtension):
	for _i in number:
		await await_idle_frame()
		server.poll()
		client.poll()

func test_network() -> void:
	var server := NetworkPeer.create(NetworkPeer.SERVER, NetworkPeer.NONE)
	var client := NetworkPeer.create(NetworkPeer.CLIENT, NetworkPeer.NONE)
	# server.set_process(false)
	# client.set_process(false)
	#ready
	add_child(server)
	add_child(client)
	
	await_poll.call_deferred(4, server.enet, client.enet)

	print_debug("TEST: frames awaited")
	await server.multiplayer.peer_connected
	assert_signal(server.multiplayer).is_emitted("peer_connected")

	print_debug("TEST: peer connected")
	
	
class MockPeer extends  Resource:
	func put_packet(pkt:PackedByteArray):
		pass
		# print("put: ", pkt)

func print_buffer(rb:ENetMultiplayerPeerExtension.RingBuffer):
	# print(range(rb.CAPACITY))
	print(rb.buf)

	# for i in rb.CAPACITY:
	# 	print(i, " ", rb.buf[i])

func test_ring_buffer() -> void:
	var rb := ENetMultiplayerPeerExtension.RingBuffer.new()
	const CAPACITY: = ENetMultiplayerPeerExtension.RingBuffer.CAPACITY
	var frame :  Array[PackedByteArray] = []

	assert_int(rb.buf.size()).is_equal(CAPACITY)
	assert_int(rb.size()).is_equal(0)

	# add
	for i in CAPACITY:
		frame.push_back([i] as PackedByteArray)
		assert_int(frame.size()).is_equal(1)
		frame = rb.add(frame)
		assert_bool(frame.is_empty()).is_true()
		if rb.is_full():
			break
	
	assert_bool(rb.is_full()).is_true()
	assert_int(rb.size()).is_equal(CAPACITY-1)
	assert_int(rb.head).is_equal(CAPACITY-1)
	assert_int(rb.tail).is_equal(0)

	# remove
	for i in CAPACITY - 1:
		assert_bool(not rb.buf[i].is_empty() == true).is_true()
		assert_bool(typeof(rb.buf[i]) == TYPE_ARRAY).is_true()
		frame = rb.remove()
		assert_int(frame.back().decode_s8(0)).is_equal(i).override_failure_message("element %d did not match index" % [i])
		frame.clear()

	assert_bool(rb.is_empty()).is_true()
	assert_int(rb.head).is_equal(CAPACITY-1)
	assert_int(rb.tail).is_equal(CAPACITY-1)


	# rb = ENetMultiplayerPeerExtension.RingBuffer.new()
	# var pp = MockPeer.new()
	# frame.clear()

	# 2 cycles
	# const DELAY := 4
	# for i in CAPACITY*2:
	# 	print("===========cycle ", i)
	# 	frame.push_back([i] as PackedByteArray)
	# 	print("add ", frame)
	# 	var empty_frame = rb.add(frame)
	# 	frame = empty_frame
	# 	frame.clear()
	# 	# build delay
	# 	if rb.size() <= DELAY:
	# 		print("delay ", empty_frame)
	# 	else:
	# 		#consume delay
	# 		while(rb.size() > DELAY) :
	# 			var frm : Array[PackedByteArray] = rb.remove()
	# 			print("remove frame ", frm)
	# 			for packet in frm :
	# 				pp.put_packet(packet)
	# 			# frame = frm
	# 			# frame.clear()
	# 	print_buffer(rb)
	# 	print("s:%d h:%d t:%d" % [rb.size(), rb.head, rb.tail])
	# print_buffer(rb)
	

		

		
