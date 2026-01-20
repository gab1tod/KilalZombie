extends Label

@export var target: Node
@export var attribute: StringName
var text_format: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_format = text
	if text_format.is_empty():
		text_format = "%s"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = text_format % target[attribute]
