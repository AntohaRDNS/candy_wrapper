class_name Game
extends Node2D


enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}
var tilemaps_path := "res://TileMaps/"
var tile_map_layer: TileMapLayer

var player_scene: PackedScene = load("uid://b17jmr687k1sm")
var goober_scene: PackedScene = load("uid://byheefdx4lxmx")

@onready var audio_win := %Audio/Win
@onready var audio_loose := %Audio/Lose
@onready var label: Label = %label
@onready var canvas_center: Node2D = $canvas_center

var clock := 0.0
var delay := 1.5
var check_win := false
var change := false



func _ready():
	global.Game = self
	
	#setup_canvas_center
	canvas_center.position = Vector2i(global.viewport_size_init.x / 2.0, global.viewport_size_init.y / 2.0)

	Goober.goobers_count = 0
		
	if global.level == global.firstLevel or global.level == global.lastLevel:
		
		label.text = tr("TITLE") if global.level == global.firstLevel else tr("GAME_COMPLITE")
		label.visible = true
		
		var p = player_scene.instantiate()
		p.position = Vector2(72, 85)
		p.scale.x = -1 if randf() < 0.5 else 1
		p.set_script(null)
		canvas_center.add_child(p)
	
	MapLoad()
	

func _process(delta):
	clock += delta
	# title screen is the first level, and "game complete" screen is the last level:
	if Input.is_action_just_pressed("ui_accept") and (global.level == global.firstLevel or (global.level == global.lastLevel  and clock > 0.5)):
		global.level = posmod(global.level + 1, global.lastLevel + 1)
		DoChange()
	
	MapChange(delta)


func MapLoad():
	print("--- MapLoad ---")
	var next_level_idx = min(global.level, global.lastLevel)
	var tml = load(tilemaps_path + "Map_" + str(next_level_idx) + ".tscn").instantiate()
	canvas_center.add_child(tml)
	tile_map_layer = tml.get_child(0)
	
	print("--- MapLoad: Begin ---")
	
	for pos in tile_map_layer.get_used_cells():
		var id = tile_map_layer.get_cell_source_id(pos)
			
		if id == TILE_PLAYER:
			var inst = player_scene.instantiate()
			var position_local = tile_map_layer.map_to_local(pos)
			inst.position = position_local
			tile_map_layer.add_child(inst)
			# remove tile from map
			tile_map_layer.set_cell(pos, -1)
			
		elif id == TILE_GOOBER:
			var inst = goober_scene.instantiate()
			var position_local = tile_map_layer.map_to_local(pos)
			inst.position = position_local
			tile_map_layer.add_child(inst)
			#goobers_parent.add_child(inst)
			# remove tile from map
			tile_map_layer.set_cell(pos, -1)
			
	print("--- MapLoad: End ---")


func MapChange(delta):
	# if its time to change scene
	if change:
		delay -= delta
		if delay < 0:
			DoChange()
		return # skip the rest if change == true
	
	# should i check_win?
	if check_win:
		check_win = false
		if Goober.goobers_count == 0:
			Win()


func Lose():
	change = true
	audio_loose.play()
	
	label.text = tr("GAME_OVER")
	label.visible = true
	
	global.level = max(0, global.level - 1)


func Win():
	change = true
	audio_win.play()
	
	label.text = tr("LEVEL_COMPLITE")
	await get_tree().create_timer(0.5).timeout
	label.visible = true
		
	global.level = min(global.lastLevel, global.level + 1)
	print("Level Complete!, change to level: ", global.level)


func DoChange():
	change = false
	get_tree().reload_current_scene()
	
	
func _enter_tree() -> void:
	print("ENTER TREE")
	pass
	

func _exit_tree() -> void:
	print("EXIT TREE")
	pass
