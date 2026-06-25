@tool
extends Panel

@export var item_kind: String = "":
	set(v):
		item_kind = v
		_sync()
@export var item_id: String = "":
	set(v):
		item_id = v
		_sync()
@export var tint: Color = Color(0.85, 0.78, 0.62, 1.0):
	set(v):
		tint = v
		_sync()


func _ready() -> void:
	_sync()


func _sync() -> void:
	for c in get_children():
		if c is ColorRect:
			c.color = tint
		if c is Label:
			c.text = item_id
