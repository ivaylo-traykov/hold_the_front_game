extends Node2D


@onready var bar: ProgressBar = $Bar


func set_max_health(value: int) -> void:
	bar.max_value = value


func update_health(value: int) -> void:
	bar.value = value
