extends CharacterBody2D

signal on_death
signal on_revive

@export var speed: float = 100
@export var health: int = 100
@export var hit_highlight_color := Color(18.892, 18.892, 18.892)

@export var separation_radius: float = 24
@export var separation_force: float = 100
@export var attack_damage: int = 50
var hurt := false
var dead: bool:
	set(value):
		if dead and not value:
			revive()
		elif not dead and value:
			die()
	get():
		return state == ZombieState.DEAD
@onready var animator: AnimatedSprite2D = %Animator
@onready var navigator := $NavigationAgent2D
@onready var cooldown_timer := $AttackCooldownTimer
@onready var collider := $CollisionShape2D
@onready var head_blood_emitter: CPUParticles2D = %HeadBloodEmitter
var target: Node2D

enum ZombieState { IDLE, WALKING, DEAD }
static var state_animation: Array[String] = [ 'idle', 'walk', 'death' ]
var state := ZombieState.IDLE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator.play()


@warning_ignore("unused_parameter")
func  _process(delta: float) -> void:
	if not dead:
		get_target()
		state = ZombieState.WALKING if target else ZombieState.IDLE
	
	handle_animations()
	
	if hurt:
		animator.modulate = hit_highlight_color
		await get_tree().create_timer(0.05).timeout
		animator.modulate = Color.WHITE
	hurt = false


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not target or dead:
		return
	
	navigator.target_position = target.global_position
	if navigator.is_navigation_finished():
		if navigator.is_target_reached():
			if target and not target.dead:
				attack()
			else:
				state = ZombieState.IDLE
		return
	
	var next_pos = navigator.get_next_path_position()
	var to_target = (next_pos - global_position).normalized()
	var sep = get_separation()
	
	velocity = to_target * speed + sep
	
	move_and_slide()


func get_target():
	var target_distance = (target.position - position).length() if target else 0.0
	for p in get_tree().get_nodes_in_group("Players"):
		if not target or target.dead or ((p.position - position).length() < target_distance and not p.dead):
			target = p
			target_distance = (target.position - position).length()


func handle_animations() -> void:
	var anim_name = state_animation[state]
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
		target.take_damage(attack_damage)
		cooldown_timer.start()


func take_damage(damage: int) -> void:
	if dead:
		return
		
	health -= damage
	hurt = true
	if health <= 0:
		die(true)


func revive(new_health: int = 100) -> void:
	collider.disabled = false
	modulate = Color.WHITE
	target = null
	health = new_health
	state = ZombieState.IDLE
	on_revive.emit()
	handle_animations()

func die(by_player: bool = false) -> void:
	if dead:
		return
	
	state = ZombieState.DEAD
	collider.disabled = true
	on_death.emit()
	handle_animations()
	if by_player:
		animator.set_frame_and_progress(3, 0)
	await animator.animation_finished
	var tween = get_tree().create_tween()
	tween.tween_interval(0.2)
	tween.tween_property(self, 'modulate', Color.TRANSPARENT, 0.5)
	await tween.finished
	queue_free()


func _on_animator_frame_changed() -> void:
	if dead and animator.get_frame() == 3:
		head_blood_emitter.emitting = true
