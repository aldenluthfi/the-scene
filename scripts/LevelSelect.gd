extends Control


func _ready() -> void:
	$HeaderBar/BackButton.pressed.connect(_on_back_pressed)
	_build_grid()


func _build_grid() -> void:
	var grid: GridContainer = $LevelGrid
	for child in grid.get_children():
		child.queue_free()

	for i in Levels.TOTAL:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(150, 150)
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_font_size_override("font_size", 28)
		if Levels.is_unlocked(i):
			btn.text = "%d\n%s" % [i + 1, Levels.level_name(i)]
			btn.disabled = false
			btn.pressed.connect(_on_level_pressed.bind(i))
		else:
			btn.text = "🔒\n%d" % (i + 1)
			btn.disabled = true
		grid.add_child(btn)


func _on_level_pressed(index: int) -> void:
	Levels.selected_index = index
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
