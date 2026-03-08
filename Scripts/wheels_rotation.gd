extends MeshInstance3D

func _ready() -> void:
	pass

const SPEED = 10.0

func _process(delta: float) -> void:
	rotation.x += -SPEED * delta
