extends Label

@export var target: Node
@export var attribute_path: StringName:
	set(value):
		attribute_path = value
		path_steps = value.split(".")
var path_steps: PackedStringArray
var text_format: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_format = text
	if text_format.is_empty():
		text_format = "%s"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var attribute = null
	for step in path_steps:
		attribute = attribute[step] if attribute else target[step]
	text = text_format % attribute
