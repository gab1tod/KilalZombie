extends Node2D

@export var disabled: bool = false

var in_use: bool = false

@onready var animation := $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn(world, zombie) -> void:
	if disabled:
		return
	
	in_use = true
	animation.play()
	await animation.animation_finished
	animation.frame = 0
	zombie.position = position
	world.add_child(zombie)
	in_use = false


func enable() -> void:
	disabled = false
	
func disable() -> void:
	disabled = true
