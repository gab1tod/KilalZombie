extends CanvasLayer


@onready var inhibition_timer := $InhibitionTimer
@onready var resume_button := $NinePatchRect/ResumeButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		close_menu()


func open_menu() -> void:
	if not inhibition_timer.is_stopped():
		return
	
	get_tree().paused = true
	resume_button.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	inhibition_timer.start()

func close_menu() -> void:
	if not inhibition_timer.is_stopped():
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	visible = false
	inhibition_timer.start()
	get_tree().paused = false

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_level() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/levels/MainMenu.tscn")
