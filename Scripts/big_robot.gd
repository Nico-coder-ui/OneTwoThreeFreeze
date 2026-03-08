extends RigidBody3D

var is_observing := false
var timer := 0.0
var next_turn_time := 0.0
var observe_timer := 0.0

func _ready() -> void:
	_pick_next_turn_time()
	get_tree().call_group("player", "connect_to_robot", self)

func _pick_next_turn_time() -> void:
	next_turn_time = randf_range(5.0, 10.0)
	timer = 0.0

func _process(delta: float) -> void:
	if is_observing:
		observe_timer += delta
		if observe_timer >= 3.0:
			_stop_observing()
	else:
		timer += delta
		if timer >= next_turn_time:
			_start_observing()

func _start_observing() -> void:
	is_observing = true
	observe_timer = 0.0
	$MeshInstance3D.rotation.y = PI

func _stop_observing() -> void:
	is_observing = false
	$MeshInstance3D.rotation.y = 0.0
	_pick_next_turn_time()

func on_player_moved(player) -> void:
	if is_observing and player.has_method("die"):
		var knockback_dir = (player.global_position - global_position).normalized()
		player.die(knockback_dir)
