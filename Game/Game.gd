class_name Game
extends Control

var tilemaps_path := "res://TileMaps/"
enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}
var tileMapLayer: TileMapLayer

var ScenePlayer: PackedScene = load("uid://b17jmr687k1sm")
var SceneGoober: PackedScene = load("uid://byheefdx4lxmx")
var SceneExplo: PackedScene = load("uid://c2pdo2im2v8d1")

@onready var goobers_parent := %Goobers
@onready var NodeAudioWin := $Audio/Win
@onready var NodeAudioLose := $Audio/Lose
@onready var label: Label = %label

var clock := 0.0
var delay := 1.5
var check := false
var change := false

@onready var canvas_center: Node2D = $canvas_center


func _ready():
	canvas_center.position = size/2.0
	
	global.Game = self
		
	if global.level == global.firstLevel or global.level == global.lastLevel:
		
		label.text = tr("TITLE") if global.level == global.firstLevel else tr("GAME_COMPLITE")
		label.visible = true
		
		var p = ScenePlayer.instantiate()
		p.position = Vector2(72, 85)
		p.scale.x = -1 if randf() < 0.5 else 1
		p.set_script(null)
		canvas_center.add_child(p)
	
	MapLoad()


func _process(delta):
	clock += delta
	# title screen is the first level, and "game complete" screen is the last level:
	if btn.p("jump") and (global.level == global.firstLevel or (global.level == global.lastLevel  and clock > 0.5)):
		global.level = posmod(global.level + 1, global.lastLevel + 1)
		DoChange()
	
	MapChange(delta)


func MapLoad():
	
	print("--- MapLoad ---")
	var next_level_idx = min(global.level, global.lastLevel)
	var tm = load(tilemaps_path + str(next_level_idx) + ".tscn").instantiate()
	tm.name = "TileMap"
	canvas_center.add_child(tm)
	tileMapLayer = tm
	
	print("--- MapLoad: Begin ---")
	print("global.level: ", global.level)
	
	for pos in tileMapLayer.get_used_cells():
		var id = tileMapLayer.get_cell_source_id(pos)
		
		if id == TILE_WALL:
			print(pos, ": Wall")
			var atlas = Vector2(randi_range(0, 2), randi_range(0, 2))
			tileMapLayer.set_cell(pos, TILE_WALL, atlas)
			#
		#elif id == TILE_PLAYER or id == TILE_GOOBER:
			#var p = id == TILE_PLAYER
			#print(pos, ": Player" if p else ": Goober")
			#var inst = (ScenePlayer if p else SceneGoober).instantiate()
			#
			#inst.position = tileMapLayer.map_to_local(pos) + Vector2(4, 0 if p else 1)
			#(self if p else goobers_parent).add_child(inst)
			#
			## remove tile from map
			#tileMapLayer.set_cell(pos, -1)
			
		elif id == TILE_PLAYER:
			var inst = ScenePlayer.instantiate()
			inst.position = tileMapLayer.map_to_local(pos) #+ Vector2(4, 0)
			canvas_center.add_child(inst)
			tileMapLayer.set_cell(pos, -1)
			# remove tile from map
			
		elif id == TILE_GOOBER:
			var inst = SceneGoober.instantiate()
			inst.position = tileMapLayer.map_to_local(pos) #+ Vector2(4, 1)
			goobers_parent.add_child(inst)
			# remove tile from map
			tileMapLayer.set_cell(pos, -1)
			
	print("--- MapLoad: End ---")


func MapChange(delta):
	# if its time to change scene
	if change:
		delay -= delta
		if delay < 0:
			DoChange()
		return # skip the rest if change == true
	
	# should i check?
	if check:
		check = false
		var count = goobers_parent.get_child_count()
		print("Goobers: ", count)
		if count == 0:
			Win()


func Lose():
	change = true
	NodeAudioLose.play()
	
	label.text = tr("GAME_OVER")
	label.visible = true
	
	global.level = max(0, global.level - 1)


func Win():
	change = true
	NodeAudioWin.play()
	
	label.text = tr("LEVEL_COMPLITE")
	label.visible = true
		
	global.level = min(global.lastLevel, global.level + 1)
	print("Level Complete!, change to level: ", global.level)


func DoChange():
	change = false
	get_tree().reload_current_scene()


func Explode(arg : Vector2):
	var xpl = SceneExplo.instantiate()
	xpl.position = arg
	add_child(xpl)
	
	
func _enter_tree() -> void:
	print("ENTER TREE")
	pass
	

func _exit_tree() -> void:
	print("EXIT TREE")
	pass
