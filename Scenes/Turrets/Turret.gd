class_name Turret extends Node2D


@export var stats: TurretStats
@export var bullet_scene: PackedScene

@onready var base_sprite: Sprite2D = $Base
@onready var turret_sprite: Sprite2D = $Turret
@onready var range: CollisionShape2D = $Range/CollisionShape
@onready var range_overlay: Sprite2D = $Range/RangeOverlay
@onready var muzzle: Marker2D = $Turret/Muzzle
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var built: bool = false
var enemies: Array[Enemy]
var target: PathFollow2D = null
var target_locked: bool = false
var can_fire: bool = true
var fire_cooldown: Timer = Timer.new()

func _ready() -> void:
	set_range(stats.range)
	range_overlay.set_visible(true)
	fire_cooldown.wait_time = stats.attack_speed
	fire_cooldown.timeout.connect(on_fire_cooldown_timeout)
	add_child(fire_cooldown)
	muzzle.get_node("Flash").hide()


func _physics_process(_delta) -> void:
	if not built:
		return
	if enemies.size() > 0:
		if not target or target not in enemies:
			target_locked = false
			target = select_enemy()
		if target_locked:
			turn(target)
			fire(target)
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


func fire(target: PathFollow2D) -> void:
	if can_fire:
		can_fire = false
		var bullet = bullet_scene.instantiate()
		bullet.direction = Vector2(cos(turret_sprite.rotation),sin(turret_sprite.rotation))
		bullet.angle = turret_sprite.rotation
		bullet.damage = stats.damage
		add_child(bullet)
		animation_player.play("muzzle_flash")
		fire_cooldown.start()


func on_fire_cooldown_timeout() -> void:
	can_fire = true
#endregion


#region Range Signals
func _on_range_body_entered(body):
	enemies.append(body.get_parent())


func _on_range_body_exited(body):
	enemies.erase(body.get_parent())
#endregion
