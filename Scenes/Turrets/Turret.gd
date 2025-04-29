class_name Turret extends Node2D


@export var stats: TurretStats

@onready var base_sprite: Sprite2D = $Base
@onready var turret_sprite: Sprite2D = $Turret
@onready var range: CollisionShape2D = $Range/CollisionShape
@onready var range_overlay: Sprite2D = $Range/RangeOverlay

var built: bool = false
var enemies: Array[Enemy]
var target: PathFollow2D = null

func _ready() -> void:
	set_range(stats.range)
	range_overlay.set_visible(true)


func _process(_delta) -> void:
	if not built:
		return
	if enemies.size() > 0:
		if not target:
			target = select_enemy()
		else:
			turn()


#region Helper Functions
func select_enemy() -> PathFollow2D:
	var target: PathFollow2D
	if enemies.size() <= 0:
		return null
	return enemies[0]


func turn() -> void:
	var enemy_position = select_enemy().get_global_position()
	turret_sprite.look_at(enemy_position)


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
