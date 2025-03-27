extends CharacterBody2D

@onready var game = global.Game
@onready var sprite := $Sprite2D
@onready var area2D := $Area2D
@onready var NodeAudio := $Audio
@onready var AnimatoinPlayer := $AnimationPlayer
@onready var raycast2D: RayCast2D = $RayCast2D

var vel := Vector2.ZERO
var vel_threshold := 400.0
var spd := 60.0
var grv := 255.0
var jump_force := 300.0

var is_on_floor := false
var is_jump := false

func _physics_process(delta):
	# gravity
	vel.y += grv * delta
	vel.y = clamp(vel.y, -vel_threshold, vel_threshold)
	
	# horizontal input
	var axis_h = Input.get_axis("ui_left", "ui_right")
	vel.x = axis_h * spd
	
	# jump
	if is_on_floor:
		if Input.is_action_just_pressed("ui_accept"):
			is_jump = true
			vel.y = -jump_force
			NodeAudio.play()
			
	elif is_jump:
		if !Input.is_action_just_pressed("ui_accept") and vel.y < jump_force / -3:
			is_jump = false
			vel.y = jump_force / -3
	
	# apply movements
	velocity = vel
	move_and_slide()
	global_position = global.wrapp(global_position)
	
	# check for Goobers
	if !check_hit():
		if velocity.y == 0:
			vel.y = 0
		
		# I check for floor 0.1 pixel down
		#is_on_floor = test_move(transform, Vector2(0, 10))
		
		# II
		is_on_floor = raycast2D.is_colliding()
	
	# sprite flip
	if axis_h != 0:
		sprite.flip_h = axis_h < 0
	
	# animation
	if is_on_floor:
		if axis_h == 0:
			try_loop_animation("Idle")
		else:
			try_loop_animation("Run")
	else:
		try_loop_animation("Jump")


func check_hit():
	var hit = false
	
	for o in area2D.get_overlapping_areas():
		var object = o.get_parent()
		print ("Overlapping: ", object.name)
		
		if object is Goober:
			var above = position.y - 1 < object.position.y
			
			if is_on_floor or (vel.y < 0.0 and !above):
				die()
			else:
				hit = true
				is_jump = Input.is_action_just_pressed("ui_accept")
				vel.y = -jump_force * (1.0 if is_jump else 0.6)
				
				object.queue_free()
				game.Explode(object.position)
				game.check = true
				print("Goober destroyed")
	return hit


func try_loop_animation(arg : String):
	if arg == AnimatoinPlayer.current_animation:
		return false
	else:
		AnimatoinPlayer.play(arg)
		return true
		
		
func die():
	queue_free()
	game.Explode(position)
	game.Lose()
