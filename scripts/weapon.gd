class_name Weapon
extends Node2D

signal on_shoot

@export var shooter: Node2D
@export var precision: float = 0.05 # radians
@export var fire_rate: float = 2 # bullet/s
@export var full_auto: bool = true
var ready_to_shoot: bool = false
var is_trigger_reset:bool = true # wether the trigger has been released between two shots
var is_trigger_pulled: bool = false

@export_group("Bullet", "bullet_")
@export var bullet_speed: float = 1000 # px/s
@export var bullet_damage: int = 5
var bullet = preload("res://scenes/Bullet.tscn")

@export_group("Crossair", "crosshair_")
@export var crosshair_distance: float = 100
@export var crosshair_fixed_distance: bool = true

var aim_angle: float = 0
var aim_distance: float = 0
var flip_h: bool = false
var flip_v: bool = false

@onready var crosshair := $Crosshair
@onready var cycle := $CycleTimer
@onready var animations := $AnimatedSprite2D
@onready var barrel := $AnimatedSprite2D/Barrel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# animations.flip_v = flip_h
	animations.scale.x = -1 if flip_h else 1
	animations.scale.y = -1 if flip_v else 1
	animations.rotation = aim_angle + (PI if flip_h else 0)
	
	var cross_dist = crosshair_distance if crosshair_fixed_distance else aim_distance
	crosshair.position = Vector2.RIGHT.rotated(aim_angle) * cross_dist
	
	if not is_trigger_pulled:
		is_trigger_reset = true
		
	if ready_to_shoot and (is_trigger_reset or full_auto) and is_trigger_pulled:
		shoot()

func shoot() -> void:
	ready_to_shoot = false
	is_trigger_reset = false
	cycle.start(1/fire_rate)
	animations.frame = 0
	animations.play()
	
	var b = bullet.instantiate()
	get_parent().get_parent().add_child(b)
	b.shooter = shooter
	b.speed = bullet_speed
	b.damage = bullet_damage
	b.direction = Vector2.RIGHT.rotated(aim_angle + randf_range(-precision, precision))
	b.global_position = barrel.global_position
	b.last_position = barrel.global_position
	
	on_shoot.emit()

func _on_cycle() -> void:
	ready_to_shoot = true
