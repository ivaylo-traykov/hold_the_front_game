class_name Game extends Node


@onready var UI: CanvasLayer = $UI
@onready var map: Node = $Map.get_child(0)
@onready var turrets: Node = $Turrets

var map_node: Node2D
var build_mode: bool = false
var build_tile_position: Vector2
var valid_build_location: bool
var turret_name: String


func _ready() -> void:
	map_node = get_node("Map").get_child(0)

	for x in get_tree().get_nodes_in_group("build_buttons"):
		x.connect("pressed", Callable(self, "initiate_build_mode")
			.bind(x.stats.turret))


func _unhandled_input(event) -> void:
	if event.is_action_released("ui_cancel") and build_mode:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode:
		build_turret()
		cancel_build_mode()


func _process(delta) -> void:
	if build_mode:
		update_turret_preview()


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


func build_turret() -> void:
	if not build_mode or not valid_build_location:
		return
	var new_turret: Turret
	new_turret = load("res://Scenes/Turrets/" + turret_name + ".tscn").instantiate()
	new_turret.position = build_tile_position
	turrets.add_child(new_turret)
	new_turret.build()
	

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


#region Helper Functions
func get_tile_position() -> Vector2:
	var mouse_position = UI.get_node("HUD").get_global_mouse_position()
	var tile_map = map_node.get_node("TileMap")
	var current_tile = tile_map.local_to_map(mouse_position)
	var tile_position = tile_map.map_to_local(current_tile)
	return tile_position
#endregion
