extends Node2D

var level := 0
const firstLevel := 0
const lastLevel := 21
var Game

var original_scene_root: Game


func _ready():
	#await get_tree().create_timer(0.1).timeout
	original_scene_root = get_tree().root.get_children()[-1]


#func _input(event):
	#if event.is_action_pressed("ui_fullscreen"):
		#var win_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE if win_full else DisplayServer.MOUSE_MODE_HIDDEN)
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if win_full else DisplayServer.WINDOW_MODE_FULLSCREEN)


func wrapp(pos := Vector2.ZERO):
	var wrap_area: Vector2 = Vector2(144.0, 144.0) + original_scene_root.canvas_center.position
	return Vector2(wrapf(pos.x, 0.0, wrap_area.x), wrapf(pos.y, 0.0, wrap_area.y))
