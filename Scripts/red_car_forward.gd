extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

@export var speed: float = 0.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("DEAD")
		body.queue_free()

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var vel = global_transform.basis.z * speed
	linear_velocity.x = vel.x
	linear_velocity.z = vel.z
