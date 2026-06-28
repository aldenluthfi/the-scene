extends Control

@export var item_kind: String = "location"
@export var item_id: String = ""
var is_dropped_in_room: bool = false

@onready var bg = $BG
@onready var room_bg = $RoomBG
@onready var char_container = $CharacterContainer
@onready var char_left = $CharacterContainer/CharLeft
@onready var char_right = $CharacterContainer/CharRight
@onready var tool_icon = $ToolIcon
@onready var label = $Label

func _ready():
	if label:
		label.text = item_id.capitalize()
	update_item_visual()

func update_item_visual():
	var r_bg = get_node_or_null("RoomBG")
	var c_container = get_node_or_null("CharacterContainer")
	var c_left = get_node_or_null("CharacterContainer/CharLeft")
	var t_icon = get_node_or_null("ToolIcon")
	var default_bg = get_node_or_null("BG")
	var nama_kapital = item_id.capitalize()

	# Reset semua visibilitas awal
	if r_bg:
		r_bg.visible = false
		r_bg.texture = null
	if c_container: c_container.visible = false
	if t_icon: t_icon.visible = false
	if default_bg: default_bg.visible = true
	self.self_modulate = Color(1, 1, 1, 1)

	match item_kind:
		"location":
			var nama_file_bersih = item_id.replace(" ", "-").to_lower()
			var path = "res://assets/backgrounds/" + nama_file_bersih + ".png"
			if ResourceLoader.exists(path) and r_bg:
				r_bg.texture = load(path)
				r_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				r_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				r_bg.size_flags_horizontal = Control.SIZE_FILL
				r_bg.size_flags_vertical = Control.SIZE_FILL
				r_bg.visible = true
			if default_bg: default_bg.visible = false

		"character":
			if c_container and c_left:
				c_container.visible = true
				c_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				c_left.visible = true
				c_left.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				c_left.size_flags_horizontal = Control.SIZE_FILL
				c_left.size_flags_vertical = Control.SIZE_FILL
				c_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				if default_bg: default_bg.visible = false

				if not is_dropped_in_room:
					c_left.custom_minimum_size = Vector2(80, 80)
					var path_char = "res://assets/characters/" + nama_kapital + ".png"
					if ResourceLoader.exists(path_char):
						c_left.texture = load(path_char)
					else:
						push_error("Texture tidak ditemukan: " + path_char)
				else:
					c_left.custom_minimum_size = Vector2(80, 80)
					var path_trans = "res://assets/characters/" + nama_kapital + "-trans.png"
					if ResourceLoader.exists(path_trans):
						c_left.texture = load(path_trans)
					else:
						push_error("Texture trans tidak ditemukan: " + path_trans)
					if r_bg: r_bg.visible = false

		"role", "hat":
			if t_icon:
				var path_icon = "res://assets/roles/" + item_id + ".png"
				if ResourceLoader.exists(path_icon):
					t_icon.texture = load(path_icon)
					t_icon.visible = true

		"tool", "item":
			if t_icon:
				var path_icon = "res://assets/tools/" + item_id + ".png"
				if ResourceLoader.exists(path_icon):
					t_icon.texture = load(path_icon)
					t_icon.visible = true
