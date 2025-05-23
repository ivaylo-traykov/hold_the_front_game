class_name UI extends CanvasLayer


@onready var preview: Control = $Preview
@onready var money: Label = $HUD/MarginContainer/VBox/Stats/Money/Amount
@onready var base_healthbar = $HUD/MarginContainer/VBox/Stats/BaseHealth/HealthBar

func get_turret_preview(turret_name: String) -> void:
	#var mouse_position = get_node("HUD").get_global_mouse_position()
	var turret_preview = load("res://Scenes/Turrets/" + turret_name + ".tscn").instantiate()
	turret_preview.set_name("TurretPreview")
	preview.add_child(turret_preview)


func update_turret_preview(new_position: Vector2, color: Color) -> void:
	if new_position.x >= 800:
		new_position.x = 800
	elif new_position.x <= 32:
		new_position.x = 32

	if new_position.y >= 608:
		new_position.y = 608
	elif new_position.y <= 32:
		new_position.y = 32

	preview.position = new_position
	preview.modulate = color


func update_money_amount(amount: int) -> void:
	money.text = str(amount)


func update_base_health(amount: int) -> void:
	base_healthbar.value = amount


func set_base_health_max(amount: int) -> void:
	base_healthbar.max_value = amount
