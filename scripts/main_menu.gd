extends CanvasLayer


@onready var start_button := $NinePatchRect/StartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_solo_game() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/SoloLevel.tscn")

func quit_game() -> void:
	get_tree().quit()


func start_duo_game() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/TwoPlayersLeve.tscn")
