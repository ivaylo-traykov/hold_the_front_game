class_name Map extends Node

@onready var paths : Array = get_node("Paths").get_children()

func _ready():
	pass


func get_paths() -> Array:
	return paths


func get_longest_path() -> Path2D:
	var path: Path2D = null
	if paths.size() > 0:
		var length: float = 0.0
		for i in paths:
			if i.get_curve().get_baked_length() > length:
				path = i
				length = i.get_curve().get_baked_length()
	return path
