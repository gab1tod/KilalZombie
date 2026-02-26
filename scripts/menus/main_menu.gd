extends CanvasLayer


@export var auto_focus: bool = true

@onready var start_button := %SoloGameButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if auto_focus:
		start_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_up")\
		or Input.is_action_just_pressed("ui_down"))\
		and not get_viewport().gui_get_focus_owner():
		start_button.grab_focus()


func start_solo_game() -> void:
	get_viewport().gui_release_focus()
	get_tree().change_scene_to_file('uid://cqv0x153qlj8c') # Solo level

func quit_game() -> void:
	get_viewport().gui_release_focus()
	get_tree().quit()


func start_duo_game() -> void:
	get_viewport().gui_release_focus()
	get_tree().change_scene_to_file('uid://db27p7c6jmlmt') # Two players level


func start_mobile_game() -> void:
	get_viewport().gui_release_focus()
	get_tree().change_scene_to_file('uid://b3lewlkl26tq6') # Mobile level
