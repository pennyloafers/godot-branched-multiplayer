extends VBoxContainer

## make sure EnetMultiplayerPeerExtension's Ringbuffer can support this
const MAX_FRAME_DELAY:int = 30

signal frame_delay(value : int)

func _ready() -> void:
	$SpinBox.max_value = MAX_FRAME_DELAY
	$HSlider.max_value = MAX_FRAME_DELAY
	


func _on_h_slider_value_changed(value: float) -> void:
	$SpinBox.value = value
	frame_delay.emit(value)

func _on_spin_box_value_changed(value: float) -> void:
	$HSlider.value = value
	frame_delay.emit(value)
	
