extends CharacterBody2D

signal interaction_start
signal interaction_stop

@export var hit_highlight_color := Color.RED

@export_group("Movements")
var flip_h: bool = false:
	set(value):
		_flip_h(value)
@export var speed: float = 200
@export var aim_speed: float = 10
@export var aim_assist: bool = true
@export var aim_assist_angle: float = 0.5

@export_group("Game")
@export var health: int = 100
@export var score: int = 0
@export var weapon: Weapon

@export_group("Inputs")
@export var device_id: int = 0
enum AimMode { MOUSE, GAMEPAD }
@export var aim_mode = AimMode.MOUSE
@export var aim_deadzone: float = 0.1
var aim_direction := Vector2.ZERO

var hurt: bool = false
var dead: bool = false

@onready var animator := $AnimatedSprite2D
@onready var weapon_socket := $WeaponSocket
@onready var heal_timer := $HealTimer
@onready var collision_shape := $CollisionShape2D


func _ready() -> void:
	animator.play()
	for node in get_children():
		if node.is_in_group("Weapons"):
			set_weapon(node)
			break

func _process(delta: float) -> void:
	if dead:
		return
	
	handle_movement()
	move_and_slide()
	
	if Input.is_action_pressed("p%d_reload" % device_id):
		weapon.reload(weapon.magazine_capacity)
	
	if is_instance_valid(weapon):
		handle_aim(delta)
		handle_shoot()
	
	handle_animations()
	handle_interaction()

func handle_animations() -> void:
	var anim_name = "walk" if velocity.length() > 0 else "idle"
	var aim_dir = Vector2.from_angle(weapon.aim_angle)
	var looking_back = aim_dir.y < -0.33
	anim_name += "_back" if looking_back else "_face"
	if abs(aim_dir.x) > 0.33:
		anim_name += "_side"
	
	if looking_back:
		move_child(weapon_socket, 0)
	else:
		move_child(weapon_socket, get_child_count() - 1)
	
	# flip_h = aim_dir.x < 0
	
	animator.animation = anim_name
	hurt = false

func handle_movement() -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("p%d_move_left" % device_id, "p%d_move_right" % device_id)
	direction.y = Input.get_axis("p%d_move_up" % device_id, "p%d_move_down" % device_id)
	
	if direction.length() > 1:
		direction = direction.normalized()
	
	velocity = direction * speed

func handle_aim(delta: float = 0) -> void:
	if aim_mode == AimMode.GAMEPAD:
		var aim_target = Vector2.ZERO
		aim_target.x = Input.get_axis("p%d_aim_left" % device_id, "p%d_aim_right" % device_id)
		aim_target.y = Input.get_axis("p%d_aim_up" % device_id, "p%d_aim_down" % device_id)
		
		
		if aim_target.length() > aim_deadzone:
			# aim assist
			if aim_assist:
				var zombies = get_tree().get_nodes_in_group("Zombies")
				zombies.sort_custom(func(a, b):
					var delta_a = (a.global_position - weapon_socket.global_position).length()
					var delta_b = (b.global_position - weapon_socket.global_position).length()
					
					return delta_a < delta_b
				)
				for zombie in zombies:
					var delta_z = zombie.global_position - weapon_socket.global_position
					var delta_angle = abs(delta_z.angle() - aim_target.angle())
					if delta_angle <= aim_assist_angle:
						aim_target = delta_z
						break
			
			var aim_delta = aim_target.normalized() - aim_direction.normalized()
			aim_direction = aim_direction.normalized() + aim_delta * aim_speed * delta
			
			flip_h = aim_direction.x < 0
			
			weapon.aim_angle = aim_direction.angle()
			weapon.aim_distance = aim_direction.length()
			weapon.crosshair_fixed_distance = true
	else:
		aim_direction = get_global_mouse_position() - weapon_socket.global_position
		var player_aim_direction = get_global_mouse_position() - global_position
		flip_h = player_aim_direction.x < 0
		
		weapon.aim_angle = aim_direction.angle()
		weapon.aim_distance = aim_direction.length()
		weapon.crosshair_fixed_distance = false

func _flip_h(is_flipped: bool) -> void:
	animator.flip_h = is_flipped
	weapon_socket.position.x = -abs(weapon_socket.position.x) if is_flipped else abs(weapon_socket.position.x)
	if is_instance_valid(weapon):
		weapon.flip_h = is_flipped

func handle_shoot() -> void:
	weapon.is_trigger_pulled = Input.is_action_pressed("p%d_shoot" % device_id)

func handle_interaction():
	var input = "p%d_interact" % device_id
	if Input.is_action_just_pressed(input):
		interaction_start.emit(self)
	if Input.is_action_just_released(input):
		interaction_stop.emit(self)


func _input(event: InputEvent) -> void:
	# Mouse
	if event is InputEventMouseMotion:
		aim_mode = AimMode.MOUSE
	
	# Gamepad
	if event is InputEventJoypadMotion and abs(event.axis_value) > aim_deadzone:
		aim_mode = AimMode.GAMEPAD


func earn_points(points: int) -> void:
	score += points
	if aim_mode == AimMode.GAMEPAD:
		Input.start_joy_vibration(device_id, 1, 0, 0.1)

func spend_points(points: int) -> bool:
	if score < points:
		return false
	
	score -= points
	return true

func take_damage(damage: int) -> void:
	if dead:
		return
	
	health -= damage
	hurt = true
	heal_timer.start()
	if aim_mode == AimMode.GAMEPAD:
		Input.start_joy_vibration(device_id, 0, 1, 0.1)
	animator.modulate = hit_highlight_color
	# animator_material.set_shader_parameter("flash_strength", 1.0)
	await get_tree().create_timer(0.05).timeout
	animator.modulate = Color.WHITE
	# animator_material.set_shader_parameter("flash_strength", 0.0)
		
	if health <= 0:
		die()

func die() -> void:
	dead = true
	collision_shape.disabled = true
	heal_timer.stop()
	weapon_socket.hide()
	animator.play("death")


func set_weapon(wp: Weapon) -> void:
	remove_weapon()
	weapon = wp
	weapon.shooter = self
	weapon.on_shoot.connect(_on_weapon_shoots)
	
	var weapon_parent = weapon.get_parent()
	if weapon_parent:
		weapon_parent.remove_child(weapon)
	weapon_socket.add_child(weapon)
	weapon_socket.move_child(weapon, 0)
	weapon.flip_h = animator.flip_h
	handle_aim()
	
	await get_tree().process_frame
	weapon.crosshair.visibility_layer = (1 << (device_id + 1))

func remove_weapon() -> void:
	if not is_instance_valid(weapon):
		return
	
	weapon.shooter = null
	weapon.on_shoot.disconnect(_on_weapon_shoots)
	weapon.queue_free()
	weapon = null

func _on_weapon_shoots() -> void:
	if aim_mode == AimMode.GAMEPAD:
		Input.start_joy_vibration(device_id, 0, 1, 0.1)


func _on_heal_timer_timeout() -> void:
	if not dead:
		health = 100
