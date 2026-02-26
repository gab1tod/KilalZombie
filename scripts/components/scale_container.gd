@tool
extends Container
class_name ScaleContainer



@export var content_scale: float = 1:
	set(value):
		content_scale = value
		update_content_scale()


func _ready() -> void:
	update_content_scale()


func update_content_scale() -> void:
	scale = Vector2(content_scale, content_scale)
