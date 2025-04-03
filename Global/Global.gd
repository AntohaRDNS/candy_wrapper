extends Node2D

var level := 0
const firstLevel := 0
const lastLevel := 21
var Game
var viewport_size_init: Vector2i


func _ready():
	# viewport_size_init остается неизменнм для display/window/stretch/mode = viewport; aspect = keep
	viewport_size_init = Vector2i(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass


func _input(event: InputEvent) -> void:
	if(event is InputEventKey):
		if((event.is_action_pressed("ui_home"))):
			get_tree().paused = !get_tree().paused
	pass


func wrapp(pos := Vector2.ZERO):
	#var t = DisplayServer.screen_get_size()
	#var wrap_area: Vector2 = Vector2(144.0, 144.0) + Game.canvas_center.position
	return Vector2(wrapf(pos.x, 0.0, viewport_size_init.x), wrapf(pos.y, 0.0, viewport_size_init.y))
