extends Control

# Variabel ekspor yang sudah kamu miliki di Inspector sebelumnya
@export var item_kind: String = "location" # contoh: "location", "character", "tool"
@export var item_id: String = ""           # contoh: "ward-room", "daniel", "poison"

@onready var bg = $BG # Panel background bawaan kamu (jika masih dipakai untuk outline/style)
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

# Fungsi utama pengatur visual dinamis
func update_item_visual():
	# Gunakan get_node_or_null agar jika node tidak ketemu, game tidak langsung crash
	var r_bg = get_node_or_null("RoomBG")
	var c_container = get_node_or_null("CharacterContainer")
	var c_left = get_node_or_null("CharacterContainer/CharLeft")
	var t_icon = get_node_or_null("ToolIcon")
	var default_bg = get_node_or_null("BG")
	
	# Ambil path gambar berdasarkan item_id
	var texture_path = "res://assets/" + item_id + ".png"
	var texture_asset = null
	
	if ResourceLoader.exists(texture_path):
		texture_asset = load(texture_path)
	
	# Lakukan pengecekan aman (hanya ubah .visible jika nodenya VALID / tidak null)
	if r_bg: r_bg.visible = false
	if c_container: c_container.visible = false
	if t_icon: t_icon.visible = false
	
	match item_kind:
		"location":
			if r_bg and texture_asset:
				r_bg.visible = true
				r_bg.texture = texture_asset
			if default_bg: 
				default_bg.visible = false # Sembunyikan panel bawaan untuk ruangan
				
		"character":
			if c_container and c_left and texture_asset:
				c_container.visible = true
				c_left.visible = true
				c_left.texture = texture_asset
			if default_bg: 
				default_bg.visible = true # Tetap tampilkan bingkai untuk karakter
				
		"tool", "role", "hat", "item":
			if t_icon and texture_asset:
				t_icon.visible = true
				t_icon.texture = texture_asset
			if default_bg: 
				default_bg.visible = true
