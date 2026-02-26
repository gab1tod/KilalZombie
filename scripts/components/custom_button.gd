@tool
extends BaseButton
class_name CustomButton


@export var text: String:
	set(value):
		text = value
		update_label()
@export var label_settings: LabelSettings:
	set(value):
		label_settings = value
		update_label()

@export_group("Background", "background_")
@export var background_normal: Color = Color.BLACK:
	set(value):
		background_normal = value
		update_background()
@export var background_hovered: Color = Color.DIM_GRAY:
	set(value):
		background_hovered = value
		update_background()
@export var background_focused: Color = Color.GRAY:
	set(value):
		background_focused = value
		update_background()
@export var background_pressed: Color = Color.WHITE:
	set(value):
		background_pressed = value
		update_background()


@onready var label: Label = %Label
@onready var background: NinePatchRect = %Background


func _ready() -> void:
	update_label()
	update_background()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	update_background()


func update_label() -> void:
	if label:
		label.text = text
		label.label_settings = label_settings

func update_background() -> void:
	if not background:
		return
	
	if button_pressed:
		background.self_modulate = background_pressed
	elif is_hovered():
		background.self_modulate = background_hovered
	elif has_focus():
		background.self_modulate = background_focused
	else:
		background.self_modulate = background_normal
