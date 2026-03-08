extends RigidBody3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)

@export var speed: float = 0.0

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("die"):
		var knockback_dir = global_transform.basis.z.normalized()
		body.die(knockback_dir)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var vel = global_transform.basis.z * speed
	linear_velocity.x = vel.x
	linear_velocity.z = vel.z
