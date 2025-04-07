extends CharacterBody2D


enum State {IDLE, WALK, JUMP, FALL}
var state: State = State.IDLE

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
@export var jump_force := 200.0

var is_on_floor := false
var is_jump := false


func _physics_process(delta):
	
	state = State.IDLE
	
	# gravity
	_velocity.y += gravity * delta
	_velocity.y = clamp(_velocity.y, -_velocity_threshold, _velocity_threshold)
	
	# horizontal input
	var axis_h = Input.get_axis("ui_left", "ui_right")
	_velocity.x = axis_h * speed
	
	# sprite flip
	if axis_h != 0:
		sprite.flip_h = axis_h < 0
	
	# is on floor
	is_on_floor = raycast2D.is_colliding()
	
	# jump
	if is_on_floor and Input.is_action_just_pressed("ui_accept"):
		is_jump = true
		_velocity.y = -jump_force
		audio.play()

	# check hit
	for o in area2D.get_overlapping_areas():
		var object = o.get_parent()
		
		if object is Goober:
			var is_player_above = (position.y - 1) < (object.position.y)
			
			# player fall down and goober is above
			if is_on_floor or (_velocity.y < 0.0 and !is_player_above):
				die()
				
			else:
				_velocity.y = -jump_force
				
				object.queue_free()
				game.Explode(object.position)
				game.check = true
	
	# animation
	if is_on_floor:
		if axis_h == 0:
			try_loop_animation("Idle")
		else:  
			try_loop_animation("Run")
	else:
		try_loop_animation("Jump")
	
	# apply movements
	velocity = _velocity
	move_and_slide()
	global_position = global.wrapp(global_position)


func try_loop_animation(arg : String):
	if arg == animation_player.current_animation:
		return false
	else:
		animation_player.play(arg)
		return true
		
		
func die():
	queue_free()
	game.Explode(position)
	game.Lose()
