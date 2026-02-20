extends Node2D
class_name BaseLevel


@onready var walls: TileMapLayer = %Walls
@onready var floor: TileMapLayer = %Floor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make the nav tile transparent
	var tileset_source = walls.tile_set.get_source(0)
	var tile_data = tileset_source.get_tile_data(Vector2i(6, 0), 0)
	tile_data.modulate = Color.TRANSPARENT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
