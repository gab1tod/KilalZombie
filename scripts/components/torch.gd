extends Node2D

static var nb_torch = 0

var noise := FastNoiseLite.new()
var lifetime: float = 0

@onready var light: PointLight2D = %PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.seed = nb_torch
	nb_torch += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifetime += delta * 50
	var noise_value = noise.get_noise_1d(lifetime)
	light.energy = 1 + noise_value * 0.1
	light.texture_scale = 2 + noise_value * 0.5
