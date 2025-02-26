extends ENetMultiplayerPeerExtensionPassthrough

class_name ENetMultiplayerPeerExtension

var _frame_buffer : Array[PackedByteArray]
var delay_ring_buffer : RingBuffer # lock free

var network_frame_delay : int = 2

func _init():
	super()
	_frame_buffer.resize(32)
	delay_ring_buffer = RingBuffer.new() 

## we use put_packet to delay because get_packet looks at
## channel, transfer mode, and sending peer for the packet.
## So instead of trying to save all the meta details of the
## packet just use the simpler approach. 
# gdscript only as _put_packet() uses native parameters
func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	if p_buffer.size() == 7:
		print(p_buffer)
		print(Time.get_datetime_string_from_system())
	_frame_buffer.push_back(p_buffer)
	return OK

func _poll() -> void:
	delay_put_packet()
	enet.poll()


func delay_put_packet():
	# add frame
	var empty_frame = delay_ring_buffer.add(_frame_buffer)

	# build delay
	if delay_ring_buffer.size() < network_frame_delay:
		_frame_buffer = empty_frame
		_frame_buffer.clear()
		return

	#consume delay
	while(delay_ring_buffer.size() > network_frame_delay) :
		var frame : Array[PackedByteArray] = delay_ring_buffer.remove()
		for packet in frame :
			enet.put_packet(packet)
		_frame_buffer = frame
		_frame_buffer.clear()


#NOTE: rember do not add specific delay behavior here manage outside of this class
class RingBuffer extends Resource:
	const CAPACITY:int = 512
	var buf:Array[Array]
	var head:int = 0
	var tail:int = 0

	func _init():
		buf.resize(CAPACITY)
		# Fill the Buffer
		print("filling")
		for i in CAPACITY:
			var empty_frame : Array[PackedByteArray] = []
			empty_frame.resize(32)
			buf[i] = empty_frame
			

	### Will return null frame if buffer is not filled first in _init
	func add(frame:Array[PackedByteArray]) -> Array[PackedByteArray]:
		var ret_frame :  Array[PackedByteArray]
		# return the empty frame for re-use
		ret_frame = buf[head]
		buf[head]=frame
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
			return head + CAPACITY + 1 - tail
