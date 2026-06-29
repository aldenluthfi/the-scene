extends Node

# Autoloaded singleton so F11 toggles fullscreen on every screen.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var w := get_window()
		if event.keycode == KEY_F11:
			w.mode = Window.MODE_WINDOWED if w.mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
		elif event.keycode == KEY_ESCAPE and w.mode == Window.MODE_FULLSCREEN:
			w.mode = Window.MODE_WINDOWED
