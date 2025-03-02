extends ENetMultiplayerPeerExtensionPassthrough

class_name ENetMultiplayerPeerExtension

var _frame_buffer : Array[PackedByteArray]
var delay_ring_buffer : RingBuffer # lock free

var network_frame_delay : int = 0
var jitter_enabled : bool = false
var jitter : bool = false
var jitter_chance : float = 0.5
var jitter_min : int = 1
var jitter_max : int = 5
var jitter_frame : Array[PackedByteArray] = []
var jitter_frame_count : int = 0

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
	if jitter :
		jitter_frame.push_back(p_buffer)
	else:
		if network_frame_delay != 0:
			_frame_buffer.push_back(p_buffer)
		else:
			enet.put_packet(p_buffer)
	return OK


func _poll() -> void:
	if network_frame_delay != 0:
		delay_put_packet()
	enet.poll()

	# complete jitter
	jitter_frame_count -= 1
	if jitter and jitter_frame_count <= 0:
		jitter = false
		for pkt:PackedByteArray in jitter_frame:
			_put_packet_script(pkt)
		jitter_frame.clear()

	# setup jitter
	if jitter_enabled and jitter == false:
		jitter = randf() < jitter_chance
		jitter_frame_count = 0
		if jitter:
			jitter_frame_count = randi_range(jitter_min, jitter_max)


func delay_put_packet():
	# add frame
	var empty_frame = delay_ring_buffer.add(_frame_buffer)
	_frame_buffer = empty_frame
	_frame_buffer.clear()

	# build delay, then consume extra
	while(delay_ring_buffer.frame_count() >= network_frame_delay) :
		var frame : Array[PackedByteArray] = delay_ring_buffer.remove()
		for packet in frame :
			enet.put_packet(packet)


## NOTE: REMEMBER! do not add specific delay behavior here manage outside of this class
class RingBuffer extends Resource:
	const CAPACITY:int = 32
	var buf:Array[Array]
	var head:int = 0
	var tail:int = 0

	func _init():
		buf.resize(CAPACITY)
		# Fill the Buffer
		for i in CAPACITY:
			buf[i] = [] as Array[PackedByteArray]
			

	### Will return null frame if buffer is not filled first in _init
	func add(frame:Array[PackedByteArray]) -> Array[PackedByteArray]:
		var ret_frame :  Array[PackedByteArray]
		# return the empty frame for re-use
		ret_frame = buf[head]
		buf[head] = frame
		if is_full():
			print("dropped frame")
			tail = _increment(tail)
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
	
	func frame_count() -> int:
		if head >= tail:
			return head - tail
		else:
			return head + CAPACITY - tail
