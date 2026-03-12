@tool
extends Area2D
class_name SpawnerRoom


@export var disabled: bool = false:
	set(value):
		disabled = value
		for s in spawners:
			s.disabled = value
@export var spawners: Array[Node2D]
@export var neighbors: Array[SpawnerRoom]
var players: Array[Player]


func _enter_tree() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _exit_tree() -> void:
	body_entered.disconnect(_on_body_entered)
	body_exited.disconnect(_on_body_exited)


func _ready() -> void:
	for s in spawners:
		s.disabled = disabled


func has_players() -> bool:
	return not players.is_empty()

func enable() -> void:
	disabled = false

func disable() -> void:
	disabled = true


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		players.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		players.erase(body)
