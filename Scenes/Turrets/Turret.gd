class_name Turret extends Node2D


@export var stats: TurretStats

@onready var base_sprite: Sprite2D = $Base
@onready var turret_sprite: Sprite2D = $Turret
@onready var range: CollisionShape2D = $Range/CollisionShape
@onready var range_overlay: Sprite2D = $Range/RangeOverlay

var built: bool = false
var enemies: Array[Enemy]
var target: PathFollow2D = null
var target_locked: bool = false


func _ready() -> void:
	set_range(stats.range)
	range_overlay.set_visible(true)


func _physics_process(_delta) -> void:
	if not built:
		return
	if enemies.size() > 0:
		if not target or target not in enemies:
			target_locked = false
			target = select_enemy()
		if target_locked:
			turn(target)
		else:
			switch_target(target)


#region Helper Functions
func select_enemy() -> PathFollow2D:
	var target: PathFollow2D
	if enemies.size() <= 0:
		return null
	return enemies[0]


func turn(target: PathFollow2D) -> void:
	var enemy_position: Vector2 = target.get_global_position()
	turret_sprite.look_at(enemy_position)


func switch_target(target: PathFollow2D) -> void:
	var enemy_position: Vector2 = target.get_global_position()
	var angle: float = rad_to_deg(turret_sprite.global_position.angle_to_point(enemy_position))
	var current: float = turret_sprite.rotation_degrees
	var abs_angle: float
	var abs_current: float
	var new_direction: float
	
	abs_angle = fposmod(angle, 360)
	abs_current = fposmod(current, 360)
	
	new_direction = abs_angle - abs_current
	if new_direction > 180:
		new_direction -= 360
	
	var tween: Tween = create_tween()
	tween.tween_property(turret_sprite, "rotation_degrees", current + new_direction, 0.1)
	await tween.finished
	target_locked = true


func build() -> void:
	built = true
	range_overlay.set_visible(false)


func set_range(range) -> void:
	var scaling = range / 600.0
	self.range.get_shape().set_radius(range / 2)
	self.range_overlay.scale = Vector2(scaling, scaling)
#endregion


#region Range Signals
func _on_range_body_entered(body):
	enemies.append(body.get_parent())


func _on_range_body_exited(body):
	enemies.erase(body.get_parent())
#endregion
