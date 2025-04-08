extends CharacterBody2D
class_name Player


enum States {IDLE, WALK, JUMP, FALL}
var state: States = States.IDLE

@onready var game = global.Game
@onready var sprite := $Sprite2D
@onready var area2D := $Area2D
@onready var audio := $Audio
@onready var animation_player: AnimationPlayer = $AnimationPlayer
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
	
	# on the ground
	if(raycast2D.is_colliding() and state != States.JUMP):
		if(axis_h != 0):
			state = States.WALK
			_play_animation_if_not_already_player("Run")
			
		if(axis_h == 0):
			state = States.IDLE
			_play_animation_if_not_already_player("Idle")
			
		if (Input.is_action_just_pressed("ui_accept")):  # после нажатия кнопки прыжка, персонаж отрывается от земли не сразу, а через несколько кадров, поэтому необходимо проверять state == States.JUMP  
			state = States.JUMP
			_velocity.y = -jump_force
			audio.play()
			#print("JUMP")
			_play_animation_if_not_already_player("Jump")
	
	# at air
	else:
		if (velocity.y > 0):
			state = States.FALL
		
		if (velocity.y < 0):
			state = States.JUMP
					
	# check hit
	for o in area2D.get_overlapping_areas():
		var object = o.get_parent()
		
		if object is Goober:
			var is_player_above = (position.y - 1) < (object.position.y)
			
			# player fall down and goober is above
			if state == States.IDLE or (_velocity.y < 0.0 and !is_player_above):
				_destroy()
			else:
				_velocity.y = -jump_force
				object.destroy()
				game.check_win = true
	
	# apply movements
	velocity = _velocity
	move_and_slide()
	global_position = global.wrapp(global_position)
		
	
func _play_animation_if_not_already_player(_new_animation: String) -> void:
	if animation_player.current_animation == _new_animation:
		return
	else:
		animation_player.play(_new_animation)
	pass


func _destroy():
	queue_free()
	game.Explode(position)
	game.Lose()
