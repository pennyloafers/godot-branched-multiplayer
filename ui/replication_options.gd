extends VBoxContainer

class_name ReplicationOptions

var syncers:Array[Node] = []
@export var tree : Tree

var root : TreeItem

func _ready() -> void:
	root = tree.create_item()
	root.set_text(0, "Synched Properties")

func reset():
	print(name, ": reset")
	tree.clear()
	root = tree.create_item()
	root.set_text(0, "Synched Properties")
	

func _on_tree_item_edited() -> void:
	var item = tree.get_edited()
	match item.get_cell_mode(0) :
		TreeItem.CELL_MODE_RANGE:
			print("item edited: %s %f" % [ item.get_parent().get_text(0), item.get_range(0)])
			var function: = item.get_metadata(0) as Callable
			if function:
				function.call(item.get_range(0))
		TreeItem.CELL_MODE_CHECK:
			print("CheckBox item edited: %s is %s" % [item.get_text(0), item.is_checked(0)])
			# if top item change all children
			if item.get_metadata(0) is StringName and item.get_metadata(0) == &"propogate":
				for subitem:TreeItem in item.get_children():
					if subitem.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK:
						tree.set_selected(subitem,0)
						tree.edit_selected()
			else:
				var callables : Array = item.get_metadata(0)
				if not callables.is_empty():
					var callable : Callable = callables[int(item.is_checked(0))]
					callable.call()
		TreeItem.CELL_MODE_STRING:
			print("String item edited: %s is %s" % [item.get_text(0), item.is_checked(0)])


func parse_syncer( syncer:MultiplayerSynchronizer, scene_path:NodePath ) -> void:
	print(name, ": parse")

	# Tree Item: Sync Node name and path, allow master enable/disable==================
	var item := tree.create_item(root)
	item.set_cell_mode(0,TreeItem.CELL_MODE_CHECK)
	create_title_item(item, "%s %d" % [scene_path, syncer.get_multiplayer_authority()])
	item.set_collapsed_recursive(false)
	item.set_checked(0,true)
	item.set_editable(0,true)
	item.set_metadata(0,&"propogate")

	# Sub Syncer options sync intervals, uses function binds to set values of specific
	var sub_item = tree.create_item(item)
	create_title_item(sub_item, "Replication Interval")
	sub_item = tree.create_item(sub_item)
	sub_item.set_metadata(0, Callable(syncer.set_replication_interval))
	create_range_item(sub_item, [0.0, 5.0, 0.001] as Array[float], syncer.replication_interval)
	sub_item = tree.create_item(item)
	create_title_item(sub_item, "Delta Interval")
	sub_item = tree.create_item(sub_item)
	sub_item.set_metadata(0, Callable(syncer.set_delta_interval))
	create_range_item(sub_item, [0.0, 5.0, 0.001] as Array[float], syncer.delta_interval)
	# Tree ============================

	var synced_properties : Array[NodePath] = syncer.replication_config.get_properties()
	for property_path:NodePath in synced_properties:
		var config : SceneReplicationConfig = syncer.replication_config
		var sync_node : StringName = property_path.get_concatenated_names()
		var sync_prop : StringName = property_path.get_concatenated_subnames()
		var rep_mode : int = config.property_get_replication_mode(property_path) 
		var enabled : bool = rep_mode != SceneReplicationConfig.REPLICATION_MODE_NEVER
		var on_spawn = config.property_get_spawn(property_path)
		var non_relative_node = (" -> " + sync_node if sync_node.casecmp_to(".") else "")

		# Tree Item: Sync Property, checkbox flips between NEVER and initial replication mode.
		var prop_item : TreeItem = tree.create_item(item)
		create_checkbox_item(prop_item, enabled, sync_prop + non_relative_node )
		prop_item.set_collapsed_recursive(true)
		prop_item.set_metadata(0,[
			config.property_set_replication_mode.bind(property_path, SceneReplicationConfig.REPLICATION_MODE_NEVER),
			config.property_set_replication_mode.bind(property_path, rep_mode)
			])
		# sub propeties option items: replication mode, on spawn
		var sub_prop_item = tree.create_item(prop_item)
		create_range_item(sub_prop_item, "Never,Always,OnChange", rep_mode)
		sub_prop_item = tree.create_item(prop_item)
		create_checkbox_item(sub_prop_item, on_spawn, "OnSpawn")
		# Tree ============================
	#Collapse tree deffered so all treeitems render once and avoid errors with propogate
	item.set_collapsed_recursive.call_deferred(true)


# Tree ============================
func create_title_item( item:TreeItem, title:String, collapsed:bool = true, column:int = 0) -> void:
	#set checked so title entry is not inditerminete
	item.set_checked(0,true)
	item.set_text(column, title)
	item.set_selectable(column, false)
	item.set_collapsed_recursive(collapsed)

func create_checkbox_item( item:TreeItem, checked:bool, text:String, column:int = 0) -> void:
	item.set_cell_mode(column,TreeItem.CELL_MODE_CHECK)
	item.set_checked(column, checked)
	item.set_editable(column, true)
	item.set_text(column, text)
	item.set_text_alignment(column, HORIZONTAL_ALIGNMENT_LEFT)

func create_range_item( item:TreeItem, range_config:Variant, value:float, column:int = 0) -> void:
	item.set_cell_mode(column, TreeItem.CELL_MODE_RANGE)
	#set checked so title entry is not inditerminete
	item.set_checked(0,true)
	if range_config is Array[float] and range_config.size() == 3:
		item.set_range_config(column, range_config[0], range_config[1], range_config[2])
	elif range_config is String:
		item.set_text(column, range_config)
	else:
		printerr("invalid range_config")
	item.set_editable(column, true)
	item.set_range(column, value)
	item.set_text_alignment(column, HORIZONTAL_ALIGNMENT_LEFT)
	
