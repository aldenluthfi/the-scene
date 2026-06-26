extends Control

@export var item_kind: String = "location"
@export var item_id: String = ""

# Status internal untuk membedakan posisi item
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
	
	var nama_file_bersih = item_id.replace(" ", "-").to_lower()
	
	# RESET SEMUA VISIBILITAS AWAL
	if r_bg: 
		r_bg.visible = false
		r_bg.texture = null
	if c_container: c_container.visible = false
	if t_icon: t_icon.visible = false
	if default_bg: default_bg.visible = true
	
	# Matikan background gelap panel utama
	if has_theme_stylebox_override("panel") or is_class("Panel") or is_class("PanelContainer"):
		add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	self.self_modulate = Color(1, 1, 1, 0)
	
	match item_kind:
		"location":
			var path = "res://assets/backgrounds/" + nama_file_bersih + ".png"
			if ResourceLoader.exists(path) and r_bg:
				r_bg.visible = true
				r_bg.texture = load(path)
			if default_bg: default_bg.visible = false
				
		"character":
			# Tambahkan baris ini di bagian paling atas blok "character"
			# Ini akan memaksa node utama Item berukuran 80x80 di dalam ItemTray
			if not is_dropped_in_room:
				self.custom_minimum_size = Vector2(80, 80)
			else:
				self.custom_minimum_size = Vector2(80, 100) # Biarkan agak tinggi saat di dalam ruangan
				
			if not c_left and c_container:
				c_left = c_container.get_node_or_null("CharLeft")
			
			if c_container and c_left:
				c_container.visible = true
				c_left.visible = true
				c_left.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				
				if not is_dropped_in_room:
					# DI TRAY: Pakai Daniel.png
					var path_tray = "res://assets/characters/" + nama_file_bersih + ".png"
					if ResourceLoader.exists(path_tray):
						c_left.texture = load(path_tray)
					c_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
					c_left.custom_minimum_size = Vector2(80, 80)
					if default_bg: default_bg.visible = false
				else:
					# DI RUANGAN (DROP): Pakai Daniel-trans.png
					var path_trans = "res://assets/characters/" + nama_file_bersih + "-trans.png"
					if ResourceLoader.exists(path_trans):
						c_left.texture = load(path_trans)
					c_left.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					c_left.custom_minimum_size = Vector2(80, 100)
					if default_bg: default_bg.visible = false
					if r_bg: r_bg.visible = false
