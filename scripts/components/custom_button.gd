extends BaseButton
class_name CustomButton


@export var content_disabled: Control
@export var content_focused: Control
@export var content_hover: Control
@export var content_normal: Control
@export var content_pressed: Control


func _process(delta: float) -> void:
	hide_contents()
	
	if disabled and content_disabled:
		content_disabled.show()
		return
	
	if button_pressed and content_pressed:
		content_pressed.show()
		return
	
	if has_focus() and content_focused:
		content_focused.show()
		return
	
	if is_hovered() and content_hover:
		content_hover.show()
		return
	
	if content_normal:
		content_normal.show()	


func hide_contents() -> void:
	if content_disabled: content_disabled.hide()
	if content_focused: content_focused.hide()
	if content_hover: content_hover.hide()
	if content_normal: content_normal.hide()
	if content_pressed: content_pressed.hide()
