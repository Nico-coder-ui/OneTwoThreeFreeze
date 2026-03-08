extends CharacterBody3D

func _ready():
	add_to_group("player")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const KNOCKBACK_FORCE = 15.0

var is_dead := false
var knockback_velocity := Vector3.ZERO

func die(knockback_dir: Vector3) -> void:
	if is_dead:
		return
	is_dead = true
	
	knockback_velocity = knockback_dir * KNOCKBACK_FORCE + Vector3.UP * 5.0
	
	var mesh = $MeshInstance3D
	var tween = create_tween()
	
	var red_material = StandardMaterial3D.new()
	red_material.albedo_color = Color(1, 0.2, 0.2, 1)
	red_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = red_material
	
	tween.tween_property(self, "rotation_degrees:x", -90.0, 0.4).set_ease(Tween.EASE_OUT)
	
	tween.tween_interval(0.3)
	
	tween.tween_property(red_material, "albedo_color:a", 0.0, 0.5)
	
	tween.tween_callback(_on_death_finished)

func _on_death_finished() -> void:
	queue_free()
	get_tree().quit()

func _physics_process(delta: float) -> void:
	if is_dead:
		knockback_velocity += get_gravity() * delta
		knockback_velocity.x = move_toward(knockback_velocity.x, 0, 5.0 * delta)
		knockback_velocity.z = move_toward(knockback_velocity.z, 0, 5.0 * delta)
		velocity = knockback_velocity
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
