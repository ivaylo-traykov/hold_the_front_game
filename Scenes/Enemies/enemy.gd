class_name Enemy extends PathFollow2D


@export var stats: EnemyStats

func _ready() -> void:
	self.set_loop(false)


func _physics_process(delta) ->void:
	set_progress(get_progress() + stats.speed * delta)
	if get_progress_ratio() == 1.0:
		die()


func die() -> void:
	queue_free()
