extends Control


func _ready() -> void:
	$CenterBox/PlayButton.pressed.connect(_on_play_pressed)
	$CenterBox/QuitButton.pressed.connect(_on_quit_pressed)
	$CenterBox/PlayButton.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
