extends VBoxContainer

## make sure EnetMultiplayerPeerExtension's Ringbuffer can support this
const MAX_FRAME_DELAY:int = 30

signal frame_delay( value : int )
signal jitter_enabled( value : bool )
signal jitter_chance( value : float )
signal jitter_range( min_value:int, max_value:int )
signal packet_loss_enabled( value : bool )
signal packet_loss_chance( value : float )


func _ready() -> void:
	$DelaySpinBox.max_value = MAX_FRAME_DELAY
	$DelaySlider.max_value = MAX_FRAME_DELAY
	dull_jitter_text(true)
	dull_loss_text(true)


func dull_loss_text(is_dull:bool):
	var color:Color = Color.DARK_GRAY if is_dull else Color.WHITE
	%PacketLossCheckButton.modulate = color
	%LossPercentage.modulate = color


func dull_jitter_text(is_dull:bool):
	var color:Color = Color.DARK_GRAY if is_dull else Color.WHITE
	%Percentage.modulate = color
	%JitterMinValue.modulate = color
	%JitterMaxValue.modulate = color
	%JitterCheckButton.modulate = color


func _on_delay_slider_value_changed(value: float) -> void:
	$DelaySpinBox.value = value
	frame_delay.emit(value)


func _on_delay_spin_box_value_changed(value: float) -> void:
	$DelaySlider.value = value
	frame_delay.emit(value)


func _on_jitter_check_button_toggled(toggled_on: bool) -> void:
	jitter_enabled.emit(toggled_on)
	dull_jitter_text(!toggled_on)


func _on_jitter_chance_value_changed(value: float) -> void:
	jitter_chance.emit(value)
	$%Percentage.text = "%2.0f%%" % [value * 100]

func _on_jitter_min_value_changed(value: float) -> void:
	var text = str(int(value))
	$%JitterMinValue.text = "Min = " + text
	if value > $%JitterMax.value:
		$%JitterMax.value = value
		$"%JitterMaxValue".text = "Max = " + text
	jitter_range.emit( value, $%JitterMax.value )


func _on_jitter_max_value_changed(value: float) -> void:
	var text = str(int(value))
	$%JitterMaxValue.text = "Max = " + text
	if value < $%JitterMin.value:
		$%JitterMin.value = value
		$"%JitterMinValue".text = "Min = " + text
	jitter_range.emit( $%JitterMin.value, value )


func _on_packet_loss_check_button_toggled(toggled_on: bool) -> void:
	packet_loss_enabled.emit(toggled_on)
	dull_loss_text(!toggled_on)


func _on_loss_chance_value_changed(value: float) -> void:
	packet_loss_chance.emit(value)
	%LossPercentage.text = "%2.0f%%" % [value * 100]
