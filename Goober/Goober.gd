extends CharacterBody2D
class_name Goober

static var goobers_count: int = 0
@onready var raycast2D := $RayCast2D
@onready var sprite := $Sprite2D
var exlosion_scene: PackedScene = load("uid://c2pdo2im2v8d1")

var spd := 30.0
var vel := Vector2(spd, 0.001)
var flip_clock := 1.0


func _ready():
	goobers_count += 1
	tree_exiting.connect(_on_free)
	# change starting direction
	randomize()
	if randf() > 0.5:
		flip()


func _physics_process(delta):
	flip_clock += delta
	
	if !raycast2D.is_colliding():
		flip()
	
	velocity = vel
	move_and_slide()
	if velocity.x == 0:
		flip()
	
	position = global.wrapp(position)


func flip():
	if flip_clock < 0.1: return
	vel.x = -vel.x
	sprite.flip_h = !sprite.flip_h
	flip_clock = 0.0
	
	
func destroy():
	var xpl = exlosion_scene.instantiate()
	xpl.position = position
	get_parent().add_child(xpl)
	queue_free()
	

func _on_free() -> void:
	goobers_count -= 1
	pass
