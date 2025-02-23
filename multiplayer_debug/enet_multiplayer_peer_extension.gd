extends ENetMultiplayerPeerExtensionPassthrough

class_name ENetMultiplayerPeerExtension

var frame_buffer : Array[PackedByteArray]
var frames_ring : DelayRingBuffer # lock free

func _init():
	super()
	frame_buffer.resize(32)
	frames_ring = DelayRingBuffer.new(10) 

## we use put_packet to delay because get_packet looks at
## channel, transfer mode, and sending peer for the packet.
## So instead of trying to save all the meta details of the
## packet just use the simpler approach. 
# gdscript only as _put_packet() uses native parameters
func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	frame_buffer.push_back(p_buffer)
	return OK


func _poll() -> void:
	delay()
	enet.poll()

func delay():
	frames_ring.add(frame_buffer)
	var frame : Array[PackedByteArray] = frames_ring.remove()
	for packet in frame :
		enet.put_packet(packet)
	frame_buffer = frame
	frame_buffer.clear()

class DelayRingBuffer extends Object:
	var _CAPACITY:int = 2
	var buf:Array[Array]
	var head:int = 0
	var tail:int = 0

	func _init(buffer_size : int= 2):
		if buffer_size < 2:
			buffer_size = 2
			printerr("size cannot be smaller then 2")
		_CAPACITY = buffer_size
		buf.resize(_CAPACITY)
		for i in _CAPACITY - 1:
			add([] as Array[PackedByteArray])
			buf[head - 1].resize(32)

	func add(frame:Array[PackedByteArray]):
		buf[head]=frame
		if is_full():
			remove()
			print("dropped frame")
		head = _increment(head)

	func _increment(index:int)->int:
		index += 1
		if index == _CAPACITY: # avoid modulus
			index = 0
		return index

	func remove() -> Array[PackedByteArray]:
		var frame : Array[PackedByteArray] = []
		#print("size ", frame.size())
		if not is_empty():
			frame = buf[tail]
			tail = _increment(tail)
		return frame

	func is_empty() -> bool:
		return tail == head

	func is_full() -> bool:
		return _increment(head) == tail # full
	
	func size() -> int:
		if head >= tail:
			return head - tail
		return head + _CAPACITY + 1 - tail
