extends Control


func _ready() -> void:
	# Memastikan Node ada sebelum menghubungkan signal untuk menghindari crash
	var back_button := get_node_or_null("HeaderBar/BackButton")
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		
	_build_grid()


func _build_grid() -> void:
	var grid := get_node_or_null("LevelGrid") as GridContainer
	if not grid:
		push_error("LevelGrid tidak ditemukan di scene!")
		return

	# Membersihkan sisa tombol lama di grid secara aman
	for child in grid.get_children():
		child.queue_free()

	# Generate tombol level berdasarkan total data di autoload Levels
	for i in Levels.TOTAL:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(150, 150)
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_font_size_override("font_size", 28)
		
		if Levels.is_unlocked(i):
			btn.text = "%d\n%s" % [i + 1, Levels.level_name(i)]
			btn.disabled = false
			# Menggunakan bind bawaan Godot 4 yang bersih dan optimal
			btn.pressed.connect(_on_level_pressed.bind(i))
		else:
			btn.text = "🔒\n%d" % (i + 1)
			btn.disabled = true
			
		grid.add_child(btn)


func _on_level_pressed(index: int) -> void:
	Levels.selected_index = index
	# Menggunakan call_deferred agar perpindahan scene mulus setelah frame ini selesai
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Main.tscn")


func _on_back_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/TitleScreen.tscn")