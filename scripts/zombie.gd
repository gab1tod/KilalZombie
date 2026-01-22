extends CharacterBody2D

signal on_death

@export var speed: float = 100
@export var health: int = 100
@export var hit_highlight_color := Color(18.892, 18.892, 18.892)

@export var separation_radius: float = 24
@export var separation_force: float = 100
@export var damage: int = 50
var hurt := false
@onready var animator = $AnimatedSprite2D
@onready var navigator := $NavigationAgent2D
@onready var cooldown_timer := $AttackCooldownTimer
var target: Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator.play()


func  _process(delta: float) -> void:
	var target_distance = (target.position - position).length() if target else 0
	for p in get_tree().get_nodes_in_group("Players"):
		if not target or (p.position - position).length() < target_distance:
			target = p
			target_distance = (target.position - position).length()


func _physics_process(delta: float) -> void:
	if not target:
		return
	navigator.target_position = target.global_position
	if navigator.is_navigation_finished():
		if navigator.is_target_reached():
			attack()
		return
	
	var next_pos = navigator.get_next_path_position()
	var to_target = (next_pos - global_position).normalized()
	var sep = get_separation()
	
	velocity = to_target * speed + sep
	
	handle_animations()
	move_and_slide()
	
	if hurt:
		animator.modulate = hit_highlight_color
		await get_tree().create_timer(0.05).timeout
		animator.modulate = Color.WHITE
	hurt = false

func handle_animations() -> void:
	var anim_name = "walk" if velocity.length() > 0 else "idle"
	var dir = velocity.normalized()
	anim_name += "_back" if dir.y < -0.33 else "_face"
	if abs(dir.x) > 0.33:
		anim_name += "_side"
	
	animator.flip_h = dir.x < 0
	
	animator.animation = anim_name


func get_separation() -> Vector2:
	var force = Vector2.ZERO

	for z in get_tree().get_nodes_in_group("Zombies"):
		if z == self:
			continue

		var diff = global_position - z.global_position
		var dist = diff.length()

		if dist > 0 and dist < separation_radius:
			force += diff.normalized() * (1.0 - dist / separation_radius)

	return force * separation_force


func attack() -> void:
	if cooldown_timer.is_stopped():
		target.take_damage(damage)
		cooldown_timer.start()


func take_damage(damage: int):
	health -= damage
	hurt = true
	if health <= 0:
		on_death.emit()
		queue_free()
