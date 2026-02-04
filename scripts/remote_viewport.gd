extends SubViewport

@export var reference: SubViewport
@export var camera: Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if reference:
		world_2d = reference.world_2d
	
	camera.make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
