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

<<<<<<< Updated upstream
func _ready():
	if label:
		label.text = item_id.capitalize()
=======
const HAT_FILES := {
	"doctor": "Doctor",
	"nurse": "Nurse",
	"patient": "Patient",
	"detective": "Deerstalker",
}

func _ready() -> void:
>>>>>>> Stashed changes
	update_item_visual()

func update_item_visual() -> void:
	var r_bg = get_node_or_null("RoomBG")
	var c_container = get_node_or_null("CharacterContainer")
	var c_left = get_node_or_null("CharacterContainer/CharLeft")
	var t_icon = get_node_or_null("ToolIcon")
	var default_bg = get_node_or_null("BG")
	var nama_kapital = item_id.capitalize()

<<<<<<< Updated upstream
	# Reset semua visibilitas awal
=======
	if lbl:
		lbl.text = nama_kapital

>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
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
=======
				var tex_path := ""
				if is_dropped_in_room:
					var ra: Array = _get_variant_role_action()
					var role: String = ra[0]
					var action: String = ra[1]
					
					if role != "":
						if action != "":
							var path_variant: String = "res://assets/characters/" + nama_kapital + "-" + role + "-" + action + ".png"
							if ResourceLoader.exists(path_variant):
								tex_path = path_variant
						
						if tex_path == "":
							var path_role_only: String = "res://assets/characters/" + nama_kapital + "-" + role + ".png"
							if ResourceLoader.exists(path_role_only):
								tex_path = path_role_only

					if tex_path == "":
						var path_trans: String = "res://assets/characters/" + nama_kapital + "-trans.png"
						if ResourceLoader.exists(path_trans):
							tex_path = path_trans
							
				if tex_path == "":
					var path_char: String = "res://assets/characters/" + nama_kapital + ".png"
					if ResourceLoader.exists(path_char):
						tex_path = path_char
						
				if tex_path != "":
					c_left.texture = load(tex_path)
>>>>>>> Stashed changes

		"role", "hat":
			if t_icon:
				var path_icon = "res://assets/roles/" + item_id + ".png"
				if ResourceLoader.exists(path_icon):
					t_icon.texture = load(path_icon)
					t_icon.visible = true

		"tool", "item":
<<<<<<< Updated upstream
			if t_icon:
				var path_icon = "res://assets/tools/" + item_id + ".png"
				if ResourceLoader.exists(path_icon):
					t_icon.texture = load(path_icon)
					t_icon.visible = true
=======
			_show_full_icon(r_bg, "res://assets/item/" + nama_kapital + ".png")


func _show_full_icon(r_bg: TextureRect, path: String) -> void:
	if r_bg and ResourceLoader.exists(path):
		r_bg.texture = load(path)
		r_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r_bg.visible = true


func _get_variant_role_action() -> Array:
	var attachments := get_node_or_null("Attachments")
	if not attachments:
		return ["", ""]
		
	var hat := ""
	var held := ""
	
	for a in attachments.get_children():
		var kind: String = a.get("item_kind")
		if kind in ["hat", "role"]:
			hat = a.get("item_id")
		elif kind in ["tool", "item"]:
			held = a.get("item_id")
			
	match hat:
		"nurse":
			if held == "handcuff":
				return ["Nurse", "Borgol"]
			elif held == "poison":
				return ["Nurse", "Poison"]
			else:
				return ["Nurse", ""]
				
		"doctor":
			return ["Doctor", "Diagnose"]
			
		"patient":
			var items_holder = get_parent()
			if items_holder and items_holder.name == "ItemsHolder":
				for sibling in items_holder.get_children():
					if sibling != self and sibling.get("item_kind") == "character":
						if sibling.has_method("_is_nurse_with_poison") and sibling._is_nurse_with_poison():
							return ["Patient", "Poisoned"]
							
			if held == "poison":
				return ["Patient", "Poisoned"]
			else:
				return ["Patient", ""]
				
		"detective":
			if held == "handcuff":
				return ["Detective", "Arrest"]
			else:
				return ["Detective", ""]
				
	return ["", ""]


func _is_nurse_with_poison() -> bool:
	var attachments := get_node_or_null("Attachments")
	if not attachments:
		return false
		
	var has_nurse_hat := false
	var has_poison := false
	
	for a in attachments.get_children():
		var id = a.get("item_id")
		var kind = a.get("item_kind")
		if kind in ["hat", "role"] and id == "nurse":
			has_nurse_hat = true
		elif kind in ["tool", "item"] and id == "poison":
			has_poison = true
			
	return has_nurse_hat and has_poison
>>>>>>> Stashed changes
