extends Control

var _level: LevelConfig


func _ready() -> void:
	_level = Levels.get_config(Levels.selected_index)
	var title := get_node_or_null("HeaderBar/Title")
	if title:
		title.text = "👑 " + _level.title
	var back := get_node_or_null("HeaderBar/BackButton")
	if back:
		back.pressed.connect(_on_back_pressed)

	for item in $ItemTray.get_children():
		_wire_draggable(item)
		if item.has_method("update_item_visual"):
			item.update_item_visual()

	for panel in $PanelGrid.get_children():
		var holder := panel.get_node("ItemsHolder")
		panel.set_drag_forwarding(Callable(), _can_drop_general, _drop_to_container.bind(holder))
	$ItemTray.set_drag_forwarding(Callable(), _can_drop_general, _drop_to_container.bind($ItemTray))


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")


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
	return kind in ["hat", "item", "role", "tool"]


func _drop_to_container(_at_pos: Vector2, data: Variant, container: Node) -> void:
	var src: Node = data.source
	var src_parent: Node = src.get_parent()
	var target_node: Node = src
	var old_owner := _owning_character(src_parent)

	if src_parent == $ItemTray:
		if container == $ItemTray:
			return
		target_node = src.duplicate()
		target_node.item_kind = src.item_kind
		target_node.item_id = src.item_id
		container.add_child(target_node)
	elif container == $ItemTray:
		src.queue_free()
		if old_owner:
			old_owner.update_item_visual.call_deferred()
		_refresh_all_visuals()
		return
	elif src_parent != container:
		src.reparent(container)

	if container != $ItemTray:
		var current_kind = target_node.get("item_kind")
		var current_id = target_node.get("item_id")
		var is_attachment := container.name == "Attachments"

		if current_kind == "location":
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
			_refresh_all_visuals()
			return

		elif current_kind == "character":
			target_node.custom_minimum_size = Vector2(120, 150)
			if target_node.has_method("update_item_visual"):
				target_node.is_dropped_in_room = true
				target_node.update_item_visual()

			for sibling in container.get_children():
				if sibling == target_node:
					continue
				if sibling.get("item_kind") == "character":
					sibling.custom_minimum_size = Vector2(120, 150)
					sibling.is_dropped_in_room = true
					if sibling.has_method("update_item_visual"):
						sibling.update_item_visual()

		elif is_attachment:
			# Worn hats/held tools aren't shown directly. Keep one hat + one tool max,
			# replacing any existing attachment of the same category.
			var new_is_hat: bool = target_node.get("item_kind") in ["hat", "role"]
			for child in container.get_children():
				if child == target_node:
					continue
				var child_is_hat: bool = child.get("item_kind") in ["hat", "role"]
				if child_is_hat == new_is_hat:
					child.queue_free()

	# Refresh the character that just received (or lost) an attachment.
	var new_owner := _owning_character(container)
	if new_owner:
		new_owner.update_item_visual()
	if old_owner and old_owner != new_owner:
		old_owner.update_item_visual.call_deferred()

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

	_refresh_all_visuals()


# Menyegarkan seluruh visual kamar, kondisi menang, dan efek komik secara sekuensial
func _refresh_all_visuals() -> void:
	for panel in $PanelGrid.get_children():
		var holder = panel.get_node_or_null("ItemsHolder")
		if holder:
			for child in holder.get_children():
				if child.has_method("update_item_visual"):
					child.update_item_visual()
					
	_check_win.call_deferred()
	_update_story_effects.call_deferred()


# Returns the character Panel that owns an Attachments container, or null.
func _owning_character(node: Node) -> Node:
	if node and node.name == "Attachments":
		var owner_node := node.get_parent()
		if owner_node and owner_node.get("item_kind") == "character":
			return owner_node
	return null


func _check_win() -> void:
	var ok := 0
	for i in 4:
		if _panel_ok(i):
			ok += 1
	$WinLabel.visible = (ok == 4)


func _panel_ok(idx: int) -> bool:
	if idx >= _level.panel_conditions.size():
		return false
		
	var holder := $PanelGrid.get_child(idx).get_node("ItemsHolder")
	for c in _level.panel_conditions[idx]:
		var condition_type = c.get("type") if c is Dictionary else c.type
		var role_id = c.get("role", "") if c is Dictionary else c.role
		var char_id = c.get("character", "") if c is Dictionary else c.character
		var item_id = c.get("item", "") if c is Dictionary else c.item

		match condition_type:
			PanelCondition.Type.HAS_ROLE:
				if _find_role(holder, role_id, char_id) == null:
					return false
			PanelCondition.Type.HAS_ITEM:
				if not _has_item_anywhere(holder, item_id):
					return false
			PanelCondition.Type.HAS_ROLE_AND_CHAR_HOLDS:
				var role_char := _find_role(holder, role_id, char_id)
				if role_char == null or not _char_holds(role_char, item_id):
					return false
	return true


# Finds a character in the holder wearing hat_id. If char_id is set, that
# character's item_id must match it exactly.
func _find_role(holder: Node, hat_id: String, char_id: String = "") -> Node:
	for c in holder.get_children():
		if c.get("item_kind") != "character":
			continue
		if char_id != "" and c.get("item_id") != char_id:
			continue
		var attachments := c.get_node_or_null("Attachments")
		if attachments:
			for a in attachments.get_children():
				if a.get("item_kind") in ["hat", "role"] and a.get("item_id") == hat_id:
					return c
	return null


func _has_item_anywhere(holder: Node, item_id: String) -> bool:
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
			if a.get("item_kind") in ["item", "tool"] and a.get("item_id") == item_id:
				return true
	return false


func _update_story_effects() -> void:
	var panel_4 := $PanelGrid.get_child(3) if $PanelGrid.get_child_count() > 3 else null
	if not panel_4:
		return
		
	var objection_node := panel_4.get_node_or_null("ObjectionLabel")
	if objection_node:
		var is_condition_met: bool = _panel_ok(3)
		if objection_node.visible != is_condition_met:
			objection_node.visible = is_condition_met