extends Node2D

@export var world: Node2D
@export var wave: int = 0

@export_group("Zombie waves")
@export var announcer_fade_duration: float = 1
@export var announcer_remain_duration: float = 1.5

@export_subgroup("Number", "nb_zombies")
@export var nb_zombies_base: int = 5
@export var nb_zombies_linear: float = 2
@export var nb_zombies_exponential: float = 1.2
var nb_zombies_to_spawn: int = 0
var nb_zombies_to_kill: int = 0

@export_subgroup("Health", "hp_zombies")
@export var hp_zombies_base: int = 89
@export var hp_zombies_linear: float = 10
@export var hp_zombies_exponential: float = 1.8
var wave_zombies_health: int = 0

@export_subgroup("Spawn interval", "spawn_time")
@export var spawn_time_base: float = 5.2
@export var spawn_time_linear: float = -0.2
var wave_spawn_time: float = 0

var Zombie = preload("res://scenes/Zombie.tscn")
@onready var viewport1 = $ViewportPlayer1/Viewport
@onready var viewport2 = $ViewportPlayer2/Viewport
@onready var walls = world.get_node("Walls")

@onready var announcer_label := $HUD/Announcer
@onready var pause_menu := $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Make background black
	$Background.show()
	
	# Make the nav tile transparent
	var tileset_source = walls.tile_set.get_source(0)
	var tile_data = tileset_source.get_tile_data(Vector2i(6, 0), 0)
	tile_data.modulate = Color.TRANSPARENT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.open_menu()


func _on_spawn_timer_timeout() -> void:
	if nb_zombies_to_spawn <= 0:
		print("No more zombies to spawn")
		$SpawnTimer.stop()
		return
	
	var spawn_points = get_tree().get_nodes_in_group("SpawnPoints")
	var spawner = spawn_points.pick_random()
	if not spawner:
		printerr("Missing spawn point")
		return
	while spawner.in_use or spawner.disabled:
		spawner = spawn_points.pick_random()
	
	var zombie = Zombie.instantiate()
	zombie.health = wave_zombies_health
	zombie.on_death.connect(_on_zombie_death)
	nb_zombies_to_spawn -= 1
	spawner.spawn(world, zombie)

func _on_zombie_death() -> void:
	nb_zombies_to_kill -= 1
	if nb_zombies_to_kill <= 0:
		$RestTimer.start()

func _on_rest_timer_timeout() -> void:
	# Start new wave
	wave += 1
	nb_zombies_to_spawn = get_nb_zombies()
	nb_zombies_to_kill = nb_zombies_to_spawn
	wave_zombies_health = get_hp_zombies()
	wave_spawn_time = get_spawn_time()
	$SpawnTimer.start(wave_spawn_time)
	announce('Wave %d' % wave)

func get_nb_zombies() -> int:
	return floor(nb_zombies_base + wave * nb_zombies_linear + pow(wave, nb_zombies_exponential))

func get_hp_zombies() -> int:
	return floor(hp_zombies_base + wave * hp_zombies_linear + pow(wave, hp_zombies_exponential))
	
func get_spawn_time() -> int:
	return max(spawn_time_base + wave * spawn_time_linear, 0)

func announce(text) -> void:
	announcer_label.text = text
	
	var tween = get_tree().create_tween()
	announcer_label.show()
	tween.tween_property(announcer_label, "modulate", Color.WHITE, announcer_fade_duration)
	tween.tween_interval(announcer_remain_duration)
	tween.tween_property(announcer_label, "modulate", Color.TRANSPARENT, announcer_fade_duration)
	tween.tween_callback(func(): announcer_label.hide())


func find_subviewports(node: Node, result: Array[SubViewport] = []) -> Array[SubViewport]:
	if node is SubViewport:
		result.append(node)
	for child in node.get_children():
		find_subviewports(child, result)
	return result
