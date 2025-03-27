class_name Map
extends Node2D


@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var map_offset: Vector2 = Vector2.ZERO 


func _ready() -> void:
	_place_pivot_to_center()
	pass


func _place_pivot_to_center() -> void:
	var tile_size = tile_map_layer.tile_set.tile_size
	
	var width_in_tiles = tile_map_layer.get_used_rect().size[0]
	var width_in_pixels = width_in_tiles * tile_size.x
	
	var hight_in_tiles = tile_map_layer.get_used_rect().size[1]
	var hight_in_pixels = hight_in_tiles * tile_size.y 
	
	map_offset.x = width_in_pixels / 2.0
	map_offset.y = hight_in_pixels / 2.0
	
	tile_map_layer.position.x -= map_offset.x
	tile_map_layer.position.y -= map_offset.y
	
	pass
