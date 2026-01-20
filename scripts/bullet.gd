extends Node2D

@export var speed: float
@export var direction: Vector2
@export var damage: int = 25
var last_position: Vector2
var shooter: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_position = global_position


func _physics_process(delta: float) -> void:
	last_position = global_position
	var displacement = direction * speed * delta
	var next_position = last_position + displacement
	
	var hit = raycast(last_position, next_position)
	if hit :
		on_hit(hit)
	else:
		global_position = next_position
	
	$Line2D.points[0] = -displacement

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
