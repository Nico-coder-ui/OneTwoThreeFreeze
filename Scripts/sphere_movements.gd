extends RigidBody3D

@export var speed: float = 8.0
var direction: float = 1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("die"):
		var knockback_dir = global_transform.basis.z.normalized()
		body.die(knockback_dir)

func _physics_process(delta: float) -> void:
	global_position.x += direction * speed * delta

func flip_direction() -> void:
	direction *= -1.0
