extends CanvasLayer

func _ready() -> void:
	visible = false
	$ColorRect/VBoxContainer/ContinueButton.pressed.connect(_on_continue)
	$ColorRect/VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_resume()
		else:
			_pause()

func _pause() -> void:
	visible = true
	get_tree().paused = true

func _resume() -> void:
	visible = false
	get_tree().paused = false

func _on_continue() -> void:
	_resume()

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Level/menu.tscn")
