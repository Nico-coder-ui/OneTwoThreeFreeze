extends Node3D

const CAR_SCENE = preload("res://red_car.tscn")
var timer = 0.0
var spawn_interval = 0

func _ready() -> void:
	randomize()


func _process(delta):
	timer += delta
	if timer >= spawn_interval or timer == 0.0:
		timer = 0.0
		spawn_interval = randi() % 5 + 3
		print(spawn_interval)
		var car = CAR_SCENE.instantiate()
		car.speed = 10.0
		get_parent().add_child(car)
		car.global_position = global_position
		car.global_rotation = global_rotation
