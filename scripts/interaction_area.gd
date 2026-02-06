extends Area2D

signal interaction_success(player: Player)
signal enter_interaction_area(player: Player)
signal exit_interaction_area(player: Player)
signal start_interaction(player: Player)
signal stop_interaction(player: Player)


@export var enabled: bool = true:
	set(value):
		enabled = value
		if not enabled:
			players.clear()
			for p in interacting_players:
				_on_body_exited(p)
			if label: label.hide()
@export var label: Control
@export_range(0, 60) var duration: float = 0.2

var players: Array[Player]
var interacting_players: Dictionary[Player, SceneTreeTimer]

var requirement:Callable = func(a): return a != null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if not enabled:
		return
	
	if body is Player:
		enter_interaction_area.emit(body)
		players.append(body)
		body.interaction_start.connect(_on_player_interaction_start)
		body.interaction_stop.connect(_on_player_interaction_stop)
		update_label_visibility_layer()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		exit_interaction_area.emit(body)
		players.erase(body)
		_on_player_interaction_stop(body)
		
		body.interaction_start.disconnect(_on_player_interaction_start)
		body.interaction_stop.disconnect(_on_player_interaction_stop)
		update_label_visibility_layer()


func _on_player_interaction_start(player) -> void:
	if not (enabled or requirement.call(player)):
		return
	
	start_interaction.emit(player)
	var interaction_timer = get_tree().create_timer(duration)
	interacting_players[player] = interaction_timer
	await interaction_timer.timeout
	if player in interacting_players:
		interaction_success.emit(player)
		interacting_players.erase(player)

func _on_player_interaction_stop(player) -> void:
	stop_interaction.emit(player)
	var interaction_timer = interacting_players.get(player)
	interacting_players.erase(player)
	if interaction_timer:
		interaction_timer.set_time_left(0)
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
