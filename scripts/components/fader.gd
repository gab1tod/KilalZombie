extends CanvasItem

signal fading_out
signal faded_out
signal fading_in
signal faded_in


@export var fade_duration: float = 0.5
@export var target: CanvasItem:
	set(value):
		if value:
			target = value
		else:
			target = self


func _ready() -> void:
	if not target:
		target = self
	
	if not target.visible:
		target.modulate = Color.TRANSPARENT


func fade_out() -> void:
	fading_out.emit()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(target, 'modulate', Color.TRANSPARENT, fade_duration)
	tween.tween_callback(target.hide)
	tween.tween_callback(faded_out.emit)

func fade_in() -> void:
	fading_in.emit()
	
	target.show()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(target, 'modulate', Color.WHITE, fade_duration)
	tween.tween_callback(faded_in.emit)
