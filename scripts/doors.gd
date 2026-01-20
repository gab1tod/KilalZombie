extends StaticBody2D

signal doors_openinig
signal doors_closing

@export var flip_h: bool = false
@export var is_open: bool = false
@export var cost: int = 750
@export var interaction_time: float = 0.3

var players: Array[Node2D]
var interacting_players: Array[Node2D]

@onready var left_door_animator := $LeftDoorAnimator
@onready var right_door_animator := $RightDoorAnimator
@onready var center_collision_shape := $CentralCollisionShape
@onready var cost_label := $CostLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_open:
		left_door_animator.frame = left_door_animator.sprite_frames.get_frame_count() - 1
		right_door_animator.frame = right_door_animator.sprite_frames.get_frame_count() - 1
		center_collision_shape.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	left_door_animator.scale.x = -1 if flip_h else 1
	cost_label.visible = not (players.is_empty() or is_open) 
	
	cost_label.text = '%d$' % cost


func open() -> void:
	if is_open:
		return
	
	is_open = true
	doors_openinig.emit()
	left_door_animator.play()
	right_door_animator.play()
	center_collision_shape.disabled = true

func close() -> void:
	if not is_open:
		return
	
	is_open = false
	doors_closing.emit()
	left_door_animator.play_backwards()
	right_door_animator.play_backwards()
	await left_door_animator.animation_finished
	center_collision_shape.disabled = false


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		players.append(body)
		body.on_interaction_start.connect(_on_player_interaction_start)
		body.on_interaction_stop.connect(_on_player_interaction_stop)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Players"):
		players.erase(body)
		interacting_players.erase(body)
		body.on_interaction_start.disconnect(_on_player_interaction_start)
		body.on_interaction_stop.disconnect(_on_player_interaction_stop)
	

func _on_player_interaction_start(player) -> void:
	if is_open or player.score < cost:
		return
	
	interacting_players.append(player)
	await get_tree().create_timer(interaction_time).timeout
	if player in interacting_players:
		player.spend_points(cost)
		interacting_players.clear()
		open()


func _on_player_interaction_stop(player) -> void:
	interacting_players.erase(player)
