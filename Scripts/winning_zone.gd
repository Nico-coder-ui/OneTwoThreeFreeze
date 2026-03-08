extends Area3D

var win_label: Label
var has_won := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("player") and not has_won:
		has_won = true
		body.is_dead = true
		_show_win_screen()

func _show_win_screen() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var font = load("res://Assets/UI/blue_winter.ttf")

	win_label = Label.new()
	win_label.text = "You Win !!"
	win_label.add_theme_font_override("font", font)
	win_label.add_theme_font_size_override("font_size", 180)
	win_label.add_theme_color_override("font_color", Color.WHITE)
	win_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	win_label.add_theme_constant_override("shadow_offset_x", 4)
	win_label.add_theme_constant_override("shadow_offset_y", 4)
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.anchors_preset = Control.PRESET_FULL_RECT
	win_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	win_label.modulate.a = 0.0
	canvas.add_child(win_label)

	var tween = create_tween()
	tween.tween_property(win_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(win_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_go_to_menu)

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://Level/menu.tscn")
