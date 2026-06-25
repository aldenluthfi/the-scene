extends Control


func _ready() -> void:
	for item in $ItemTray.get_children():
		_wire_draggable(item)
	for panel in $PanelGrid.get_children():
		var holder := panel.get_node("ItemsHolder")
		panel.set_drag_forwarding(Callable(), _can_drop_general, _drop_to_container.bind(holder))
	$ItemTray.set_drag_forwarding(Callable(), _can_drop_general, _drop_to_container.bind($ItemTray))


func _wire_draggable(item: Control) -> void:
	var is_in_panel := item.get_parent() != $ItemTray
	if item.get("item_kind") == "character" and is_in_panel:
		var attachments := item.get_node("Attachments")
		item.set_drag_forwarding(
			_drag_from.bind(item),
			_can_drop_on_character,
			_drop_to_container.bind(attachments),
		)
	else:
		item.set_drag_forwarding(_drag_from.bind(item), Callable(), Callable())


func _drag_from(_at_pos: Vector2, item: Control) -> Variant:
	var preview := Panel.new()
	preview.custom_minimum_size = item.size
	preview.modulate = Color(1, 1, 1, 0.8)
	var bg := ColorRect.new()
	bg.color = item.get("tint")
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
	return kind == "hat" or kind == "item"


func _drop_to_container(_at_pos: Vector2, data: Variant, container: Node) -> void:
	var src: Node = data.source
	var src_parent: Node = src.get_parent()
	if src_parent == $ItemTray:
		if container == $ItemTray:
			return
		var clone: Node = src.duplicate()
		container.add_child(clone)
		_wire_draggable(clone)
	elif container == $ItemTray:
		src.queue_free()
	elif src_parent != container:
		src.reparent(container)
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
		var attachments := c.get_node("Attachments")
		for a in attachments.get_children():
			if a.get("item_kind") == "hat" and a.get("item_id") == hat_id:
				return c
	return null


func _has_role(holder: Node, hat_id: String) -> bool:
	return _find_role(holder, hat_id) != null


func _has_anywhere(holder: Node, item_id: String) -> bool:
	for c in holder.get_children():
		if c.get("item_id") == item_id:
			return true
		if c.get("item_kind") == "character":
			for a in c.get_node("Attachments").get_children():
				if a.get("item_id") == item_id:
					return true
	return false


func _char_holds(character: Node, item_id: String) -> bool:
	for a in character.get_node("Attachments").get_children():
		if a.get("item_kind") == "item" and a.get("item_id") == item_id:
			return true
	return false
