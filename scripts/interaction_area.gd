extends Area2D


signal interaction_success(player: Node2D)
signal enter_interaction_area(player: Node2D)
signal exit_interaction_area(player: Node2D)

@export var enabled: bool = true:
	set(value):
		enabled = value
		if not enabled:
			players.clear()
			interacting_players.clear()
			if label: label.hide()
@export var label: Control
@export_range(0, 60) var duration: float = 0.2

var players: Array[Node2D]
var interacting_players: Array[Node2D]

var requirement:Callable = func(a): return a != null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if not enabled:
		return
	
	if body.is_in_group("Players"):
		enter_interaction_area.emit(body)
		players.append(body)
		body.interaction_start.connect(_on_player_interaction_start)
		body.interaction_stop.connect(_on_player_interaction_stop)
		update_label_visibility_layer()


func _on_body_exited(body: Node2D) -> void:
	if not enabled:
		return
	
	if body.is_in_group("Players"):
		exit_interaction_area.emit(body)
		players.erase(body)
		_on_player_interaction_stop(body)
		
		body.interaction_start.disconnect(_on_player_interaction_start)
		body.interaction_stop.disconnect(_on_player_interaction_stop)
		update_label_visibility_layer()


func _on_player_interaction_start(player) -> void:
	if not requirement.call(player):
		return
	
	interacting_players.append(player)
	var interaction_timer = get_tree().create_timer(duration)
	await interaction_timer.timeout
	if player in interacting_players:
		interaction_success.emit(player)
		interacting_players.erase(player)

func _on_player_interaction_stop(player) -> void:
	interacting_players.erase(player)
	update_label_visibility_layer()


func update_label_visibility_layer() -> void:
	if not label:
		return
	label.show()
	
	label.visibility_layer = 0
	for player in players:
		label.visibility_layer |= 1 << (player.device_id + 1)

func is_empty() -> bool:
	return players.is_empty()
