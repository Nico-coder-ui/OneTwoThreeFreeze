extends CharacterBody3D

func _ready():
	add_to_group("player")

const SPEED = 5.0
const JUMP_VELOCITY = 6.5
const KNOCKBACK_FORCE = 15.0
const ROTATION_SPEED = 10.0  # Vitesse de rotation vers la direction
const ACCELERATION = 30.0    # Accélération au sol (mouvement progressif)
const DECELERATION = 20.0    # Décélération au sol
const AIR_CONTROL = 0.3      # Contrôle en l'air (30% du sol)

var is_dead := false
var knockback_velocity := Vector3.ZERO
var gravity_multiplier := 1.0  # Pour la gravité variable du saut

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
		if velocity.y > 0 and not Input.is_action_pressed("ui_accept"):
			velocity += get_gravity() * 2.5 * delta
		elif velocity.y < 0:
			velocity += get_gravity() * 1.8 * delta
		else:
			velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(-input_dir.x, 0, -input_dir.y).normalized()
	
	var control = ACCELERATION if is_on_floor() else ACCELERATION * AIR_CONTROL
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, control * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, control * delta)
		
		var target_angle: float
		if absf(input_dir.x) > absf(input_dir.y):
			target_angle = PI / 2 if input_dir.x > 0 else -PI / 2
		else:
			target_angle = 0.0 if input_dir.y > 0 else PI
		$MeshInstance3D.rotation.y = lerp_angle($MeshInstance3D.rotation.y, target_angle, ROTATION_SPEED * delta)
	else:
		var decel = DECELERATION if is_on_floor() else DECELERATION * AIR_CONTROL
		velocity.x = move_toward(velocity.x, 0, decel * delta)
		velocity.z = move_toward(velocity.z, 0, decel * delta)

	move_and_slide()
