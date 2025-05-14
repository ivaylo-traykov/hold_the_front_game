class_name Bullet extends Area2D


var speed: int = 1400
var direction: Vector2
var velocity: Vector2
var angle: float
var damage: int
var targets: Array

func _ready() -> void:
	velocity = direction * speed
	rotation = angle


func _physics_process(delta) -> void:
	translate(velocity * delta)
	
	if targets.size() > 0:
		targets[0].get_hit(damage)
		queue_free()


func _on_body_entered(body) ->void:
	if body.get_parent().is_in_group("enemies"):
		targets.append(body.get_parent())


func _on_visible_notifier_screen_exited() -> void:
	queue_free()
