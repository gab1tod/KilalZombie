class_name Weapon
extends Node2D

signal on_shoot
signal on_reload
signal on_reload_finished

@export var shooter: Node2D
@export var precision: float = 0.05 # radians
@export var fire_rate: float = 2 # bullet/s
@export var full_auto: bool = true
@export var burst: int = 1
@export var burst_delay: float = 0
var burst_count: int = 0
var ready_to_shoot: bool = false
var has_cycled: bool = false
var is_trigger_reset:bool = true # wether the trigger has been released between two shots
var is_trigger_pulled: bool = false

@export var magazine_capacity: int = 10
@export var amo: int = 10
var must_reload: bool = false
var is_reloading: bool = false

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
@onready var animator := $AnimatedSprite2D
@onready var barrel := $AnimatedSprite2D/Barrel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# animations.flip_v = flip_h
	animator.scale.x = -1 if flip_h else 1
	animator.scale.y = -1 if flip_v else 1
	animator.rotation = aim_angle + (PI if flip_h else 0)
	
	var cross_dist = crosshair_distance if crosshair_fixed_distance else aim_distance
	crosshair.position = Vector2.RIGHT.rotated(aim_angle) * cross_dist
	
	if not is_trigger_pulled:
		is_trigger_reset = true
	
	must_reload = amo <= 0
	ready_to_shoot = has_cycled and (is_trigger_reset or full_auto) and not (must_reload or is_reloading)
	
	if is_trigger_pulled and ready_to_shoot:
		shoot()

func shoot() -> void:
	if not ready_to_shoot:
		return
	
	has_cycled = false
	is_trigger_reset = false
	cycle.start(1/fire_rate)
	animator.frame = 0
	animator.play("fire")
	
	var b = bullet.instantiate()
	get_parent().get_parent().add_child(b)
	b.shooter = shooter
	b.speed = bullet_speed
	b.damage = bullet_damage
	b.direction = Vector2.RIGHT.rotated(aim_angle + randf_range(-precision, precision))
	b.global_position = barrel.global_position
	b.last_position = barrel.global_position
	
	on_shoot.emit()
	amo -= 1
	burst_count += 1
	if amo == 0:
		burst_count = 0
		await animator.animation_finished
		animator.animation = "reload"
		animator.frame = 0
		reload(magazine_capacity)
	elif burst_count < burst:
		if burst_delay > 0: get_tree().create_timer(burst_delay).timeout
		ready_to_shoot = true
		shoot()
	else:
		burst_count = 0

func reload(bullets: int) -> void:
	if is_reloading or amo >= magazine_capacity or bullets <= 0:
		return
	
	is_reloading = true
	
	animator.frame = 0
	animator.play("reload")
	on_reload.emit()
	await animator.animation_finished
	if shooter.aim_mode == shooter.AimMode.GAMEPAD:
		Input.start_joy_vibration(shooter.device_id, 1, 0, 0.2)
	animator.animation = "fire"
	animator.frame = animator.sprite_frames.get_frame_count("fire") - 1
	amo = bullets
	is_reloading = false
	on_reload_finished.emit()

func _on_cycle() -> void:
	has_cycled = true
