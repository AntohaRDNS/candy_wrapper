extends CharacterBody2D
class_name Player


enum States {IDLE, WALK, JUMP, FALL}
var state: States = States.IDLE

@onready var game = global.Game
@onready var sprite := $Sprite2D
@onready var area2D := $Area2D
@onready var audio := $Audio
@onready var animation_player := $AnimationPlayer
@onready var raycast2D: RayCast2D = $RayCast2D

var _velocity := Vector2.ZERO
var _velocity_threshold := 400.0
@onready var speed := 60.0
@export var gravity := 500.0
@export var jump_force := 300.0


func _ready() -> void:
	state = States.IDLE
	pass


func _physics_process(delta):
	 
	# gravity
	_velocity.y += gravity * delta
	_velocity.y = clamp(_velocity.y, -_velocity_threshold, _velocity_threshold)
	
	# horizontal input
	var axis_h = Input.get_axis("ui_left", "ui_right")
	_velocity.x = axis_h * speed
	# sprite flip
	sprite.flip_h = axis_h < 0
	
	if(raycast2D.is_colliding()):
		if axis_h == 0:
			#print("IDLE")
			state = States.IDLE
			animation_player.play("Idle")
		if axis_h != 0:
			state = States.WALK
			#print("WALK")
			animation_player.play("Run")
		if Input.is_action_just_pressed("ui_accept"):
			state == States.JUMP
			_velocity.y = -jump_force
			audio.play()
			#print("JUMP")
			animation_player.play("Jump")
			pass
	
	# check hit
	for o in area2D.get_overlapping_areas():
		var object = o.get_parent()
		
		if object is Goober:
			var is_player_above = (position.y - 1) < (object.position.y)
			
			# player fall down and goober is above
			if state == States.IDLE or (_velocity.y < 0.0 and !is_player_above):
				die()
			else:
				_velocity.y = -jump_force
				object.destroy()
				game.check_win = true
	
	# apply movements
	velocity = _velocity
	move_and_slide()
	global_position = global.wrapp(global_position)
		
		
func die():
	queue_free()
	game.Explode(position)
	game.Lose()
