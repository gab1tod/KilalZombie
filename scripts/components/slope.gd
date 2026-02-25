extends Area2D


@export var slope_ratio: float = 0.5
@export_range(0, 1) var slowing_effect: float = 0.25


func _enter_tree() -> void:
	body_entered.connect(body_enter)
	body_exited.connect(body_exit)

func _exit_tree() -> void:
	body_entered.disconnect(body_enter)
	body_exited.disconnect(body_exit)


func process_slope(body: Player) -> void:
	body.velocity.y += body.velocity.x * slope_ratio
	body.velocity *= 1 - slowing_effect


func body_enter(body: Node2D) -> void:
	if body.is_in_group('Players'):
		body.movement_handeled.connect(process_slope.bind(body))

func body_exit(body: Node2D) -> void:
	if body.is_in_group('Players'):
		body.movement_handeled.disconnect(process_slope)
