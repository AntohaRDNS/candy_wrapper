extends Node2D

var level := 0
const firstLevel := 0
const lastLevel := 21
var Game


func _ready():
	get_viewport().size_changed.connect(update_info)
	pass


func update_info() -> void:
	#print(DisplayServer.window_get_max_size())
	print(get_viewport().size)
	pass


func wrapp(pos := Vector2.ZERO):
	#var t = DisplayServer.screen_get_size()
	#var wrap_area: Vector2 = Vector2(144.0, 144.0) + Game.canvas_center.position
	return Vector2(wrapf(pos.x, 0.0, get_viewport().size.x), wrapf(pos.y, 0.0, get_viewport().size.y))
