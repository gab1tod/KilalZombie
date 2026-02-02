extends StaticBody2D


signal chest_opening
signal chest_closing


@export_group("Animation")
@export var interaction_time: float = 0.3
@export var opening_duration: float = 0.5
@export var interaction_highlight_color := Color(1.27, 1.27, 0.92)

@export_group("Item", "item_")
@export var item_resource: PackedScene
@export var item_name: String:
	set(value):
		item_name = value
		update_labels()
@export var item_cost: int = 0:
	set(value):
		item_cost = value
		update_labels()

var players: Array[Node2D]
var interacting_players: Array[Node2D]
var is_open: bool = false

@onready var animator := $AnimatedSprite2D
@onready var label := $Label
@onready var item_label := $Label/Item
@onready var cost_label := $Label/Cost


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator.frame = 5 if is_open else 0
	label.hide()
	
	update_labels()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var buyable = not (players.is_empty() or is_open)
	label.visible = buyable
	
	var modulate_color = interaction_highlight_color if buyable else Color.WHITE
	animator.modulate = modulate_color


func update_labels():
	if not is_inside_tree():
		return
	if not item_label or not cost_label:
		return
	
	item_label.text = item_name
	cost_label.text = "%d$" % item_cost


func open() -> void:
	chest_opening.emit()
	is_open = true
	animator.play()

func close() -> void:
	chest_closing.emit()
	is_open = false
	animator.play_backwards()

func grant_item(player) -> void:
	if not item_resource:
		return
	var item = item_resource.instantiate()
	player.set_weapon(item)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		players.append(body)
		body.interaction_start.connect(_on_player_interaction_start)
		body.interaction_stop.connect(_on_player_interaction_stop)
		update_label_visibility_layer()


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Players"):
		players.erase(body)
		interacting_players.erase(body)
		body.interaction_start.disconnect(_on_player_interaction_start)
		body.interaction_stop.disconnect(_on_player_interaction_stop)
		update_label_visibility_layer()

func _on_player_interaction_start(player) -> void:
	if is_open or player.score < item_cost:
		return
	
	interacting_players.append(player)
	await get_tree().create_timer(interaction_time).timeout
	if player in interacting_players:
		player.spend_points(item_cost)
		interacting_players.clear()
		open()
		await animator.animation_finished
		grant_item(player)
		await get_tree().create_timer(opening_duration).timeout
		close()

func _on_player_interaction_stop(player) -> void:
	interacting_players.erase(player)

func update_label_visibility_layer() -> void:
	label.visibility_layer = 0
	for player in players:
		label.visibility_layer |= 1 << (player.device_id + 1)
