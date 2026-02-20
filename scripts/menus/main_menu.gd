extends CanvasLayer


@onready var start_button := %SoloGameButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_solo_game() -> void:
	get_tree().change_scene_to_file('uid://cqv0x153qlj8c') # Solo level

func quit_game() -> void:
	get_tree().quit()


func start_duo_game() -> void:
	get_tree().change_scene_to_file('uid://db27p7c6jmlmt') # Two players level


func start_mobile_game() -> void:
	get_tree().change_scene_to_file('uid://b3lewlkl26tq6') # Mobile level
