extends Node3D

const minChallValue = 2
const maxChallValue = 4

const endingMapPath = "res://Level/ending_map.tscn"

const startingMapPath = "res://Level/starting_map.tscn"

const challengesPath = ["res://Level/road_challenge.tscn", "res://Level/jump_challenge.tscn", "res://Level/maze_challenge.tscn"]

func _placePlayer() -> void:
	pass

func _placeEndingMap(currentOffset) -> float:
	var endingScene = load(endingMapPath)
	var insEndingScene = endingScene.instantiate()
	add_child(insEndingScene)
	print(currentOffset)
	var lenght = insEndingScene.get_node("StaticBody3D/MeshInstance3D").get_aabb().size.z * insEndingScene.get_node("StaticBody3D/MeshInstance3D").get_scale().z
	insEndingScene.position.z = currentOffset  + lenght / 2
	print(currentOffset + lenght / 2)
	currentOffset += lenght
	print(currentOffset)
	return currentOffset

func _placeChallenges(challengesList, currentOffset) -> float:
	print(challengesList)
	for index in challengesList:
		print("BOUCLE")
		var tempScene = load(challengesPath[index])
		var insTempScene = tempScene.instantiate()
		add_child(insTempScene)
		var ground = insTempScene.find_child("Ground")
		var low_ground = ground.get_node("LowGround")
		var mesh = low_ground.get_node("MeshInstance3D")
		var length = mesh.get_aabb().size.z * mesh.get_scale().z
		var ground_offset_z = ground.position.z + low_ground.position.z
		print(currentOffset)
		insTempScene.position.z = currentOffset + length / 2 - ground_offset_z
		print(currentOffset + length / 2 - ground_offset_z)
		currentOffset += length
		print(currentOffset)
	print(currentOffset)
	return currentOffset

func _placeStartingMap(currentOffset) -> float:
	var startingScene = load(startingMapPath)
	var insStartingScene = startingScene.instantiate()
	add_child(insStartingScene)
	print(currentOffset)
	insStartingScene.position.z = currentOffset
	currentOffset += (insStartingScene.get_node("StaticBody3D/MeshInstance3D").get_aabb().size.z * insStartingScene.get_node("StaticBody3D/MeshInstance3D").get_scale().z) / 2
	print(currentOffset)
	return currentOffset

func _ready() -> void:
	randomize()
	var maxChallenges = randi() % (maxChallValue - minChallValue + 1) + minChallValue
	var challengesList = []
	var currentOffset = 0.0
	print(maxChallenges)

	for i in range(maxChallenges):
		var nbR = randi() % challengesPath.size()
		challengesList.append(nbR)
	
	currentOffset = _placeStartingMap(currentOffset)
	
	currentOffset = _placeChallenges(challengesList, currentOffset)
		
	currentOffset = _placeEndingMap(currentOffset)
	
	var pause_menu = load("res://Level/pause_menu.tscn").instantiate()
	add_child(pause_menu)

func _process(delta: float) -> void:
	pass
