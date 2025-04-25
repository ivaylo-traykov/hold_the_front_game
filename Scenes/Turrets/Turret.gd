class_name Turret extends Node2D


@export var stats: TurretStats

@onready var base_sprite: Sprite2D = $Base
@onready var turret_sprite: Sprite2D = $Turret
@onready var range: CollisionShape2D = $Range/CollisionShape
@onready var range_overlay: Sprite2D = $Range/RangeOverlay

var built: bool = false

func _ready() -> void:
	set_range(stats.range)
	range_overlay.set_visible(true)


func _process(_delta) -> void:
	if not built:
		return
		
	turn()


func turn() -> void:
	var enemy_position = get_global_mouse_position()
	turret_sprite.look_at(enemy_position)	


#region Helper Functions
func build() -> void:
	built = true
	range_overlay.set_visible(false)
	

func set_range(range) -> void:
	var scaling = range / 600.0
	self.range.get_shape().set_radius(range / 2)
	self.range_overlay.scale = Vector2(scaling, scaling)
#endregion
