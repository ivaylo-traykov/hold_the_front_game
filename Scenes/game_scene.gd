class_name Game extends Node


@onready var UI: CanvasLayer = $UI
@onready var map: Node = $Map.get_child(0)
@onready var turrets: Node = $Turrets

var build_mode: bool = false
