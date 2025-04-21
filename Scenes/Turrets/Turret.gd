class_name Turret extends Node2D


@export var stats: TurretStats

var base_sprite: Sprite2D
var turret_sprite: Sprite2D

func _ready() -> void:
	var base = Sprite2D.new()
	base.set_texture(stats.base)
	base.set_name("Base")
	base_sprite = base
	add_child(base)
	var turret = Sprite2D.new()
	turret.set_name("Turret")
	turret.set_texture(stats.sprite)
	turret.set_offset(stats.sprite_offset)
	turret_sprite = turret
	add_child(turret)


func _process(delta):
	turn()


func turn():
	var enemy_position = get_global_mouse_position()
	turret_sprite.look_at(enemy_position)
	

