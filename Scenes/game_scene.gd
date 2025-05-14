class_name Game extends Node


@onready var UI: CanvasLayer = $UI
@onready var map: Node = $Map.get_child(0)
@onready var turrets: Node = $Turrets
@onready var wave_button = $UI/HUD/MarginContainer/VBox/GameControls/WaveButton
@onready var wave_button_label = wave_button.get_node("Label")
@onready var pause_button = $UI/HUD/MarginContainer/VBox/GameControls/SpeedControls/Pause
@onready var play_button = $UI/HUD/MarginContainer/VBox/GameControls/SpeedControls/Play
@onready var forward_button = $UI/HUD/MarginContainer/VBox/GameControls/SpeedControls/FastForward

var map_node: Node2D
var build_mode: bool = false
var build_tile_position: Vector2
var valid_build_location: bool
var turret_name: String
var wave_number: int = 1
var is_wave_running: bool = false
var enemies: Array
var spawn_cooldown: Timer = Timer.new()
var can_spawn: bool = true
var wave_data: Wave
var enemies_in_wave: int
var enemies_killed: int
var base_health: int = 50


func _ready() -> void:
	map_node = get_node("Map").get_child(0)
	wave_button_label.update_text(str(wave_number))
	
	spawn_cooldown.timeout.connect(on_spaw_cooldown_timeout)
	add_child(spawn_cooldown)
	
	for x in get_tree().get_nodes_in_group("build_buttons"):
		x.connect("pressed", Callable(self, "initiate_build_mode")
			.bind(x.stats.turret))


func _unhandled_input(event) -> void:
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode:
		if build_turret() and 0:
			cancel_build_mode()


func _process(delta) -> void:
	if build_mode:
		update_turret_preview()
	
	if can_spawn and enemies.size() > 0:
		can_spawn = false
		var path: Path2D
		path = map.get_paths().pick_random()
		var enemy = enemies.pop_front()
		print("spawn enemy")
		path.add_child(enemy[0])
		spawn_cooldown.wait_time = enemy[1]
		spawn_cooldown.start()
	
	var DEBUG = get_node("DEBUG")
	DEBUG.text = 'in wave: %d \nkilled: %d' % [enemies_in_wave, enemies_killed]


#region Build Functions
func initiate_build_mode(turret: String) -> void:
	if build_mode:
		cancel_build_mode()
	build_mode = true
	turret_name = turret
	UI.get_turret_preview(turret)


func cancel_build_mode() -> void:
	build_mode = false
	UI.get_node("Preview").get_child(0).free()


func build_turret() -> bool:
	if not build_mode or not valid_build_location:
		return false
	var new_turret: Turret
	new_turret = load("res://Scenes/Turrets/" + turret_name + ".tscn").instantiate()
	new_turret.position = build_tile_position
	turrets.add_child(new_turret)
	new_turret.build()
	return true
	

func update_turret_preview() -> void:
	build_tile_position = get_tile_position()
	valid_build_location = is_valid_turret_location(build_tile_position)
	var color: Color = "3cff3c"
	if not valid_build_location:
		color = "ff3c3c"
	UI.update_turret_preview(build_tile_position, color)


func is_valid_turret_location(tile_position) -> bool:
	var tile_map: TileMap = map_node.get_node("TileMap")
	var tile_to_map_position: Vector2 = tile_map.local_to_map(tile_position)
	var has_road: bool = tile_map.get_cell_tile_data(1, tile_to_map_position) != null
	var has_prop: bool = tile_map.get_cell_tile_data(2, tile_to_map_position) != null
	var has_turret: bool = false
	for i in turrets.get_children():
		if i.position == tile_position:
			has_turret = true
			break
	return not (has_road or has_prop or has_turret) 
#endregion


#region SpawnEnemies
func on_spaw_cooldown_timeout() -> void:
	can_spawn = true


func retriev_wave_data() -> void:
	#wave_data = load("res://Resources/Levels/wave_" + str(wave_number) + ".tres") 
	wave_data = load("res://Resources/Levels/wave_" + str(1) + ".tres") 
	var result: Array 
	for sequence in wave_data.get_wave():
		for i in range(sequence["amount"]):
			var type: String = sequence["type"]
			var interval: float = sequence["interval"]
			var tank: PathFollow2D = load("res://Scenes/Enemies/" + type + ".tscn").instantiate()
			tank.enemy_killed.connect(on_enemy_killed)
			tank.hit_base.connect(on_base_hit)
			var temp_arr: Array = [tank, interval]
			result.append(temp_arr)
	enemies = result
	enemies_in_wave = enemies.size()
	enemies_killed = 0
#endregion


#region Helper Functions
func get_tile_position() -> Vector2:
	var mouse_position = UI.get_node("HUD").get_global_mouse_position()
	var tile_map = map_node.get_node("TileMap")
	var current_tile = tile_map.local_to_map(mouse_position)
	var tile_position = tile_map.map_to_local(current_tile)
	return tile_position


func on_enemy_killed() -> void:
	enemies_killed += 1
	if enemies_killed == enemies_in_wave:
		is_wave_running = false
		wave_number += 1
		wave_button_label.update_text(str(wave_number))
		wave_button.disabled = false


func on_base_hit() -> void:
	base_health -= 1
#endregion


#region Game Controls
func _on_wave_button_pressed():
	if is_wave_running:
		return
	is_wave_running = true
	wave_button.disabled = true
	retriev_wave_data()


func _on_pause_pressed():
	if build_mode:
		cancel_build_mode()
	get_tree().paused = true
	play_button.modulate = "a7a7a7"
	forward_button.modulate = "a7a7a7"
	pause_button.modulate = "fff"


func _on_play_pressed():
	get_tree().paused = false
	Engine.set_time_scale(1.0)
	forward_button.modulate = "a7a7a7"
	pause_button.modulate = "a7a7a7"
	play_button.modulate = "fff"


func _on_fast_forward_pressed():
	get_tree().paused = false
	Engine.set_time_scale(2.0)
	pause_button.modulate = "a7a7a7"
	play_button.modulate = "a7a7a7"
	forward_button.modulate = "fff"
#endregion
