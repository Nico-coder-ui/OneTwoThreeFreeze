extends Node3D

const minChallValue = 1
const maxChallValue = 3

const endingMapPath = "res://Level/ending_map.tscn"

const startingMapPath = "res://Level/starting_map.tscn"

const challengesPath = ["res://Level/road_challenge.tscn"]

func _placePlayer() -> void:
	pass

func _placeEndingMap(currentOffset) -> float:
	var endingScene = load(endingMapPath)
	var insEndingScene = endingScene.instantiate()
	add_child(insEndingScene)
	print(currentOffset)
	var lenght = insEndingScene.get_node("StaticBody3D/MeshInstance3D").get_aabb().size.z * insEndingScene.get_node("StaticBody3D/MeshInstance3D").get_scale().z
	insEndingScene.position.z = currentOffset  + lenght / 2
	currentOffset += lenght
	print(currentOffset)
	return currentOffset

func _placeChallenges(challengesList, currentOffset) -> float:
	for index in challengesList:
		var tempScene = load(challengesPath[index])
		var insTempScene = tempScene.instantiate()
		print(currentOffset)
		add_child(insTempScene)
		var ground = insTempScene.find_child("Ground")
		var length = ground.get_node("LowGround/MeshInstance3D").get_aabb().size.z * ground.get_node("LowGround/MeshInstance3D").get_scale().z
		insTempScene.position.z = currentOffset + length / 2
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
	currentOffset += insStartingScene.get_node("StaticBody3D/MeshInstance3D").get_aabb().size.z * insStartingScene.get_node("StaticBody3D/MeshInstance3D").get_scale().z
	print(currentOffset)
	return currentOffset / 2

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
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
