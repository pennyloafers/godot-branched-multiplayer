extends MultiplayerSynchronizer

class_name InputSynchronizer

func _ready() -> void:
	var root = get_node(root_path)
	var id = root.name.to_int()
	call_deferred("set_multiplayer_authority", id)
