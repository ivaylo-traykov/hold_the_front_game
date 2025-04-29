class_name Enemy extends PathFollow2D


signal enemy_killed
signal hit_base
@export var stats: EnemyStats


func _ready() -> void:
	self.set_loop(false)


func _physics_process(delta) ->void:
	set_progress(get_progress() + stats.speed * delta)
	if get_progress_ratio() == 1.0:
		hit_base.emit()
		die()


func die() -> void:
	enemy_killed.emit()
	queue_free()
