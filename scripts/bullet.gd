extends Node2D

@export var speed: float
@export var direction: Vector2
@export var damage: int = 25
@export var color := Color(0.941, 0.898, 0.329):
	set(value):
		color = value
		if line:
			line.default_color = color
	get(): return color
var last_position: Vector2
var shooter: Node2D

@onready var line := $Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_position = global_position


func _physics_process(delta: float) -> void:
	last_position = global_position
	var displacement = direction * speed * delta
	var next_position = last_position + displacement
	
	move(next_position)
	
	line.points[0] = -displacement

func move(target_pos: Vector2) -> bool:
	var hit = raycast(global_position, target_pos)
	if hit :
		on_hit(hit)
	else:
		global_position = target_pos
	
	return not hit

func on_hit(hit: Dictionary):
	var collider = hit.collider
	
	if collider.is_in_group("Zombies"):
		collider.take_damage(damage)
		shooter.earn_points(10)
	
	global_position = hit.position
	queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()

func raycast(from: Vector2, to: Vector2) -> Dictionary:
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 3
	query.exclude = [self, shooter]

	return space_state.intersect_ray(query)
