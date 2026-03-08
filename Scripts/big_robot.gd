extends RigidBody3D

var is_observing := false
var timer := 0.0
var next_turn_time := 0.0
var observe_timer := 0.0
var is_whistling := false

var whistle_canvas: CanvasLayer
var whistle_sprite: TextureRect
var whistle_player: AudioStreamPlayer

func _ready() -> void:
	_pick_next_turn_time()
	get_tree().call_group("player", "connect_to_robot", self)
	_setup_whistle_ui()

func _setup_whistle_ui() -> void:
	whistle_canvas = CanvasLayer.new()
	whistle_canvas.layer = 5
	add_child(whistle_canvas)

	whistle_sprite = TextureRect.new()
	whistle_sprite.texture = load("res://Assets/UI/whistle.png")
	whistle_sprite.position = Vector2(20, 20)
	whistle_sprite.scale = Vector2(2, 2)
	whistle_sprite.visible = false
	whistle_canvas.add_child(whistle_sprite)

	whistle_player = AudioStreamPlayer.new()
	whistle_player.stream = load("res://Assets/UI/whistle_sound.mp3")
	add_child(whistle_player)

func _pick_next_turn_time() -> void:
	next_turn_time = randf_range(5.0, 10.0)
	timer = 0.0

func _process(delta: float) -> void:
	if is_whistling:
		return
	if is_observing:
		observe_timer += delta
		if observe_timer >= 3.0:
			_stop_observing()
	else:
		timer += delta
		if timer >= next_turn_time:
			_whistle_then_observe()

func _whistle_then_observe() -> void:
	is_whistling = true
	whistle_sprite.visible = true
	whistle_player.play()
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(_finish_whistle)

func _finish_whistle() -> void:
	is_whistling = false
	_start_observing()

func _start_observing() -> void:
	is_observing = true
	observe_timer = 0.0
	$MeshInstance3D.rotation.y = PI

func _stop_observing() -> void:
	is_observing = false
	whistle_sprite.visible = false
	$MeshInstance3D.rotation.y = 0.0
	_pick_next_turn_time()

func on_player_moved(player) -> void:
	if is_observing and player.has_method("die"):
		var knockback_dir = (player.global_position - global_position).normalized()
		player.die(knockback_dir)
