extends CanvasLayer


@export var menu_parent: String = 'uid://dvgauec5bim52' # Main menu
@export var auto_focus: bool = true

@onready var inhibition_timer := $InhibitionTimer
@onready var resume_button := %ResumeButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_up")\
		or Input.is_action_just_pressed("ui_down"))\
		and not get_viewport().gui_get_focus_owner():
		resume_button.grab_focus()
	
	if Input.is_action_just_pressed("pause"):
		close_menu()


func open_menu() -> void:
	if not inhibition_timer.is_stopped():
		return
	
	get_tree().paused = true
	if auto_focus:
		resume_button.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	inhibition_timer.start()

func close_menu() -> void:
	if not inhibition_timer.is_stopped():
		return
	
	get_viewport().gui_release_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	visible = false
	inhibition_timer.start()
	get_tree().paused = false

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_level() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(menu_parent)
