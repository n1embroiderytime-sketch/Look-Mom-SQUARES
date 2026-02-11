extends Resource
class_name LevelData

# This script defines the "Shape" of a level file.
@export var level_name: String = "New Level"
@export var sequence: Array[String] = ["O", "I"]
# We use Vector2i (Integer Vector) for grid coordinates
@export var target_slots: Array[Vector2i] = []
