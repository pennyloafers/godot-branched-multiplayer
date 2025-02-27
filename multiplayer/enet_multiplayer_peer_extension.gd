extends ENetMultiplayerPeerExtensionPassthrough

class_name ENetMultiplayerPeerExtension

var _frame_buffer : Array[PackedByteArray]
var delay_ring_buffer : RingBuffer # lock free

var network_frame_delay : int = 32

func _init():
	super()
	delay_ring_buffer = RingBuffer.new() 

## we use put_packet to delay because get_packet looks at
## channel, transfer mode, and sending peer for the packet.
## So instead of trying to save all the meta details of the
## packet just use the simpler approach. 
# gdscript only as _put_packet() uses native parameters
func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	#print(peer_type, ": packet ", p_buffer)
	if network_frame_delay != 0:
		_frame_buffer.push_back(p_buffer)
	else:
		enet.put_packet(p_buffer)
	return OK

var poll_count:int
func _poll() -> void:
	if network_frame_delay != 0:
		delay_put_packet()
	poll_count+=1
	#print(peer_type, ": poll_count ", poll_count)
	enet.poll()


func delay_put_packet():
	# add frame
	var empty_frame = delay_ring_buffer.add(_frame_buffer)
	_frame_buffer = empty_frame
	_frame_buffer.clear()

	# build delay
	if delay_ring_buffer.size() <= network_frame_delay:
		pass
	else:
		#consume delay
		while(delay_ring_buffer.size() > network_frame_delay) :
			var frame : Array[PackedByteArray] = delay_ring_buffer.remove()
			for packet in frame :
				enet.put_packet(packet)


#NOTE: rember do not add specific delay behavior here manage outside of this class
class RingBuffer extends Resource:
	const CAPACITY:int = 128
	var buf:Array[Array]
	var head:int = 0
	var tail:int = 0

	func _init():
		buf.resize(CAPACITY)
		# Fill the Buffer
		for i in CAPACITY:
			var empty_frame : Array[PackedByteArray] = []
			buf[i] = empty_frame
			

	### Will return null frame if buffer is not filled first in _init
	func add(frame:Array[PackedByteArray]) -> Array[PackedByteArray]:
		var ret_frame :  Array[PackedByteArray]
		# return the empty frame for re-use
		ret_frame = buf[head]
		buf[head] = frame
		if is_full():
			remove()
			print("dropped frame")
		head = _increment(head)
		return ret_frame

	func _increment(index:int)->int:
		index += 1
		if index == CAPACITY: # avoid modulus
			index = 0
		return index

	func remove() -> Array[PackedByteArray]:
		#print("size ", frame.size())
		if is_empty():
			return [] as Array[PackedByteArray]
		else:
			var frame : = buf[tail]
			tail = _increment(tail)
			return frame

	func is_empty() -> bool:
		return tail == head

	func is_full() -> bool:
		return _increment(head) == tail # full
	
	func size() -> int:
		if head >= tail:
			return head - tail
		else:
			return head + CAPACITY - tail
