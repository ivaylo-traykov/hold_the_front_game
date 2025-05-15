class_name Enemy extends PathFollow2D


signal enemy_killed
signal hit_base
signal drop_reward

@onready var health_bar: Node2D = $HealthBar

@export var stats: EnemyStats

var health: int
var reward: int
var dead: bool = false


func _ready() -> void:
	self.set_loop(false)
	health_bar.set_max_health(stats.health)
	health_bar.update_health(stats.health)
	health_bar.hide()
	health = stats.health
	reward = stats.reward
	if not is_in_group("enemies"):
		add_to_group("enemies")


func _physics_process(delta) ->void:
	set_progress(get_progress() + stats.speed * delta)
	if get_progress_ratio() == 1.0:
		hit_base.emit()
		die()


func get_hit(damage) -> void:
	health -= damage
	if health <= 0:
		die()
		drop_reward.emit(reward)
		return
	if not health_bar.visible:
		health_bar.show()
	health_bar.update_health(health)


func die() -> void:
	if not dead:
		dead = true
		#get_node("Body/CollisionShape2D").disabled = true
		enemy_killed.emit()
		queue_free()
