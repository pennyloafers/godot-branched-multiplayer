extends VBoxContainer

class_name SceneOptions

signal split_view_change(split_view:bool)
signal scene_selected(path:String)

@export_file() var scene_path : String = ""

func is_split_view() -> bool:
	return $SplitViewCheckButton.button_pressed

func _on_split_view_check_button_toggled(toggled_on: bool) -> void:
	split_view_change.emit(toggled_on)

func _on_file_dialog_button_pressed() -> void:
	%FileDialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
	scene_path = path
	open_scene(scene_path)

func open_scene_with_current_path() -> void:
	open_scene(scene_path)

func open_scene(path:String) -> void:
	var file_name = path.get_file()
	%TextEdit.text = file_name
	var scene : Node = load(path).instantiate()
	scene.queue_free()
	scene_selected.emit(path)
	#var user_dir : String = OS.get_user_data_dir()
	#var copy_path : String = "%s/%s" % [user_dir, file_name]
	#var local_path : String = "user://%s" % [ file_name]
	#var err = DirAccess.copy_absolute(path, copy_path)
	
