extends Control


func _ready() -> void:
	for item in $ItemTray.get_children():
		_wire_draggable(item)
		if item.has_method("update_item_visual"):
			item.update_item_visual()
			
	for panel in $PanelGrid.get_children():
		var holder := panel.get_node("ItemsHolder")
		panel.set_drag_forwarding(Callable(), _can_drop_general, _drop_to_container.bind(holder))
	$ItemTray.set_drag_forwarding(Callable(), _can_drop_general, _drop_to_container.bind($ItemTray))


func _wire_draggable(item: Control) -> void:
	var is_in_panel := item.get_parent() != $ItemTray
	if item.has_method("update_item_visual"):
		item.update_item_visual()
		
	if item.get("item_kind") == "character" and is_in_panel:
		var attachments := item.get_node_or_null("Attachments")
		if attachments:
			item.set_drag_forwarding(
				_drag_from.bind(item),
				_can_drop_on_character,
				_drop_to_container.bind(attachments),
			)
		else:
			item.set_drag_forwarding(_drag_from.bind(item), Callable(), Callable())
	else:
		item.set_drag_forwarding(_drag_from.bind(item), Callable(), Callable())


func _drag_from(_at_pos: Vector2, item: Control) -> Variant:
	var preview := Panel.new()
	preview.custom_minimum_size = Vector2(80, 80)
	preview.modulate = Color(1, 1, 1, 0.8)
	
	var room_bg = item.get_node_or_null("RoomBG")
	var char_container = item.get_node_or_null("CharacterContainer")
	
	if room_bg and room_bg.visible and room_bg.texture:
		var tex := TextureRect.new()
		tex.texture = room_bg.texture
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		preview.add_child(tex)
	elif char_container and char_container.visible:
		var char_left = item.get_node_or_null("CharacterContainer/CharLeft")
		if char_left and char_left.texture:
			var tex := TextureRect.new()
			tex.texture = char_left.texture
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex.set_anchors_preset(Control.PRESET_FULL_RECT)
			preview.add_child(tex)
		else:
			var tex := TextureRect.new()
			var nama_kapital = str(item.get("item_id")).capitalize()
			var path_karakter = "res://assets/characters/" + nama_kapital + ".png"
			if ResourceLoader.exists(path_karakter):
				tex.texture = load(path_karakter)
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex.set_anchors_preset(Control.PRESET_FULL_RECT)
			preview.add_child(tex)
	else:
		var bg := ColorRect.new()
		bg.color = item.get("tint") if item.get("tint") != null else Color.DARK_GRAY
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		preview.add_child(bg)
		
	var lbl := Label.new()
	lbl.text = item.get("item_id")
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview.add_child(lbl)
	
	set_drag_preview(preview)
	return {"source": item}


func _can_drop_general(_at_pos: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("source")


func _can_drop_on_character(_at_pos: Vector2, data: Variant) -> bool:
	if not _can_drop_general(_at_pos, data):
		return false
	var kind: String = data.source.get("item_kind")
	return kind == "hat" or kind == "item" or kind == "role" or kind == "tool"


func _drop_to_container(_at_pos: Vector2, data: Variant, container: Node) -> void:
	var src: Node = data.source
	var src_parent: Node = src.get_parent()
	var target_node: Node = src
	
	if src_parent == $ItemTray:
		if container == $ItemTray:
			return
		target_node = src.duplicate()
# Akses property langsung, bukan via get()
		target_node.item_kind = src.item_kind
		target_node.item_id = src.item_id
		print("item_kind dari src.item_kind: '", src.item_kind, "'")
		container.add_child(target_node)
		print("Setelah add_child - item_kind: '", target_node.get("item_kind"), "' | item_id: '", target_node.get("item_id"), "'")
	elif container == $ItemTray:
		src.queue_free()
		_check_win.call_deferred()
		return
	elif src_parent != container:
		src.reparent(container)
	
	if container != $ItemTray:
		var current_kind = target_node.get("item_kind")
		var current_id = target_node.get("item_id")

		if current_kind == "location":
			print("current_kind: '", current_kind, "' | current_id: '", current_id, "'")
			var panel_box = container.get_parent()
			if panel_box:
				var grid_bg = panel_box.get_node_or_null("GridBG")
				var panel_bg_color = panel_box.get_node_or_null("PanelBg")
				var path_gambar = "res://assets/backgrounds/" + str(current_id).replace(" ", "-") + ".png"
				if ResourceLoader.exists(path_gambar):
					if grid_bg:
						grid_bg.texture = load(path_gambar)
						grid_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
						grid_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
						grid_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
					if panel_bg_color:
						panel_bg_color.visible = false
			target_node.queue_free()
			_check_win.call_deferred()
			return

		elif current_kind == "character":
			target_node.custom_minimum_size = Vector2(80, 80)
			if target_node.has_method("update_item_visual"):
				target_node.is_dropped_in_room = true
				target_node.update_item_visual()

			# Update semua karakter lain di container agar tidak hilang
			for sibling in container.get_children():
				if sibling == target_node:
					continue
				if sibling.get("item_kind") == "character":
					sibling.custom_minimum_size = Vector2(80, 80)
					sibling.is_dropped_in_room = true
					if sibling.has_method("update_item_visual"):
						sibling.update_item_visual()

	# Untuk karakter di panel, set drag forwarding tanpa memanggil update_item_visual
	if target_node.get("item_kind") == "character" and target_node.get_parent() != $ItemTray:
		var attachments := target_node.get_node_or_null("Attachments")
		if attachments:
			target_node.set_drag_forwarding(
				_drag_from.bind(target_node),
				_can_drop_on_character,
				_drop_to_container.bind(attachments),
			)
		else:
			target_node.set_drag_forwarding(_drag_from.bind(target_node), Callable(), Callable())
	else:
		_wire_draggable(target_node)

	_check_win.call_deferred()


func _check_win() -> void:
	var ok := 0
	for i in 4:
		if _panel_ok(i):
			ok += 1
	$WinLabel.visible = (ok == 4)


func _panel_ok(idx: int) -> bool:
	var holder := $PanelGrid.get_child(idx).get_node("ItemsHolder")
	match idx:
		0:
			return _has_role(holder, "nurse") and _has_anywhere(holder, "poison")
		1:
			return _has_role(holder, "doctor")
		2:
			return _has_role(holder, "detective")
		3:
			var nurse_char := _find_role(holder, "nurse")
			return _has_role(holder, "detective") \
				and nurse_char != null \
				and _char_holds(nurse_char, "handcuff")
	return false


func _find_role(holder: Node, hat_id: String) -> Node:
	for c in holder.get_children():
		if c.get("item_kind") != "character":
			continue
		var attachments := c.get_node_or_null("Attachments")
		if attachments:
			for a in attachments.get_children():
				if (a.get("item_kind") == "hat" or a.get("item_kind") == "role") and a.get("item_id") == hat_id:
					return c
	return null


func _has_role(holder: Node, hat_id: String) -> bool:
	return _find_role(holder, hat_id) != null


func _has_anywhere(holder: Node, item_id: String) -> bool:
	for c in holder.get_children():
		if c.get("item_id") == item_id:
			return true
		if c.get("item_kind") == "character":
			var attachments := c.get_node_or_null("Attachments")
			if attachments:
				for a in attachments.get_children():
					if a.get("item_id") == item_id:
						return true
	return false


func _char_holds(character: Node, item_id: String) -> bool:
	var attachments := character.get_node_or_null("Attachments")
	if attachments:
		for a in attachments.get_children():
			if (a.get("item_kind") == "item" or a.get("item_kind") == "tool") and a.get("item_id") == item_id:
				return true
	return false
