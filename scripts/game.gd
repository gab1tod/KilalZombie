extends Node2D

@export var world: Node2D
@export var level: Node2D
@export var wave: int = 0
@export var hide_cursor: bool = true

@export_group("Zombie waves")
@export var announcer_fade_duration: float = 1
@export var announcer_remain_duration: float = 1.5

@export_subgroup("Number", "nb_zombies")
@export var nb_zombies_base: int = 7
@export var nb_zombies_linear: float = 2
@export var nb_zombies_exponential: float = 1.2
var nb_zombies_to_spawn: int = 0
var nb_zombies_to_kill: int = 0

@export_subgroup("Health", "hp_zombies")
@export var hp_zombies_base: int = 100
@export var hp_zombies_linear: float = 10
@export var hp_zombies_exponential: float = 1.8
var wave_zombies_health: int = 0

@export_subgroup("Speed", "speed_zombies")
@export var speed_zombies_base: int = 15
@export var speed_zombies_linear: float = 2
@export var speed_zombies_max: float = 85
@export var speed_zombies_random: float = 5
var wave_zombies_speed: float = 0

@export_subgroup("Spawn interval", "spawn_time")
@export var spawn_time_base: float = 5
@export var spawn_time_linear: float = -0.2
var wave_spawn_time: float = 0

var Zombie = preload('uid://ch0wyjtx6icrd')
@onready var viewport1 = $ViewportPlayer1/Viewport
@onready var viewport2 = $ViewportPlayer2/Viewport
@onready var walls = world.get_node("Walls")

@onready var announcer_label := $HUD/Announcer
@onready var pause_menu := $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hide_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Make background black
	$Background.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.auto_focus = get_tree().get_first_node_in_group("Players").aim_mode == Player.AimMode.GAMEPAD
		pause_menu.open_menu()
	
	if Input.is_action_just_pressed("ui_accept"):
		for z in get_tree().get_nodes_in_group("Zombies"):
			z.die()


func _on_spawn_timer_timeout() -> void:
	if nb_zombies_to_spawn <= 0:
		print("No more zombies to spawn")
		$SpawnTimer.stop()
		return
	
	var spawn_rooms = get_tree().get_nodes_in_group("Rooms").filter(is_spawnable_room)
	var spawn_points = []
	for r in spawn_rooms:
		spawn_points.append_array(r.spawners)
	
	var spawner = spawn_points.pick_random()
	if not spawner:
		printerr("Missing spawn point")
		return
	while spawner.in_use or spawner.disabled:
		spawner = spawn_points.pick_random()
	
	var zombie = Zombie.instantiate()
	zombie.health = wave_zombies_health
	
	var speed_random = sqrt(randf()) * speed_zombies_random
	zombie.speed = min(wave_zombies_speed + speed_random, speed_zombies_max)
	
	zombie.on_death.connect(_on_zombie_death)
	nb_zombies_to_spawn -= 1
	spawner.spawn(world, zombie)

func is_spawnable_room(r: SpawnerRoom) -> bool:
	if r.has_players():
		return true
	for n in r.neighbors:
		if n.has_players():
			return true
	return false

func _on_zombie_death() -> void:
	nb_zombies_to_kill -= 1
	if nb_zombies_to_kill <= 0:
		$RestTimer.start()
		for p in get_tree().get_nodes_in_group('Players'):
			if p.dead:
				await get_tree().create_timer(0.5).timeout
				p.revive(null)
			p.was_revived = false

func _on_rest_timer_timeout() -> void:
	# Start new wave
	wave += 1
	nb_zombies_to_spawn = get_nb_zombies()
	nb_zombies_to_kill = nb_zombies_to_spawn
	wave_zombies_health = get_hp_zombies()
	wave_zombies_speed = get_speed_zombies()
	wave_spawn_time = get_spawn_time()
	$SpawnTimer.start(wave_spawn_time)
	announce('Wave %d' % wave)

func get_nb_zombies() -> int:
	var i = wave - 1
	return floor(nb_zombies_base + i * nb_zombies_linear + pow(i, nb_zombies_exponential))

func get_hp_zombies() -> int:
	var i = wave - 1
	return floor(hp_zombies_base + i * hp_zombies_linear + pow(i, hp_zombies_exponential))

func get_speed_zombies() -> float:
	var i = wave - 1
	return speed_zombies_base + i * speed_zombies_linear
	
func get_spawn_time() -> int:
	var i = wave - 1
	return max(spawn_time_base + i * spawn_time_linear, 0)

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


func set_level(lvl: Node2D) -> void:
	if level and level.is_inside_tree():
		level.queue_free()
	
	level = lvl
	world.add_child(level)
