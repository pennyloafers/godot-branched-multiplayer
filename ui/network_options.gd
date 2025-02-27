extends VBoxContainer

## make sure EnetMultiplayerPeerExtension's Ringbuffer can support this
const MAX_FRAME_DELAY:int = 30

signal frame_delay( value : int )
signal jitter_enabled( value : bool)
signal jitter_chance( value : float)


func _ready() -> void:
	$DelaySpinBox.max_value = MAX_FRAME_DELAY
	$DelaySlider.max_value = MAX_FRAME_DELAY
	



func _on_delay_slider_value_changed(value: float) -> void:
	$DelaySpinBox.value = value
	frame_delay.emit(value)

func _on_delay_spin_box_value_changed(value: float) -> void:
	$DelaySlider.value = value
	frame_delay.emit(value)


func _on_jitter_check_button_toggled(toggled_on: bool) -> void:
	jitter_enabled.emit(toggled_on)


func _on_jitter_chance_value_changed(value: float) -> void:
	jitter_chance.emit(value)
