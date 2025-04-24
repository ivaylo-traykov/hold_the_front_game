class_name BuildButton extends TextureButton


@export var stats: TurretStats
var button_texture: Texture2D = load("res://Assets/UI/button_square.png")


func _ready() -> void:
	set_texture_normal(button_texture)
	var button_icon = Sprite2D.new()
	button_icon.set_texture(stats.icon)
	button_icon.set_scale(stats.icon_scale)
	button_icon.set_offset(stats.icon_offset)
	button_icon.set_name("Icon")
	add_child(button_icon)
