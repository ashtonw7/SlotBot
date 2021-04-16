extends KinematicBody2D

# movements variables
export var speed := 100
export var gravity := 25
export var max_gravity := 275
export var jump_speed := 350
export var wall_jump_speed := 350 * 1.3
export var knockback_power = 500
export var friction = 0.5

var velocity := Vector2.ZERO

onready var tiles = get_parent().get_node("Tiles")

onready var body = $Body
onready var lucky_lights = body.get_node("Lights/Lucky")
onready var lucky_lights_body = body.get_node("Lights/LuckyBody")
onready var hitbox = $Hitbox
onready var hurtbox = $Hurtbox
onready var bullet_start = $BulletStart

# deal with jumping
var jumping := false
var wallJump := false
var just_wall_jumped := false

# deal with walking animation
var walking = false

# direction facing
enum {LEFT, RIGHT}
var direction = RIGHT

# current weapon
enum Weapons {DEFAULT, QUICK, BIG, SHOTGUN, LASER, BIGSHOTGUN, RAPID}
var curr_weapon = Weapons.DEFAULT

var small_bullet = preload("res://Player/Weapons/Default/DefaultBullet.tscn")

# determines whether or not you can shoot (cooldown between shots)
var can_shoot = true

# if true, player is damaged and has i-frames
var damaged = false

# random variable to increment each frame and for print statements/debugging bc 
#I'm too lazy to use real debugging tools
var i = 0

# get the movement input
func get_input():
	if not Input.is_action_pressed('right') and not Input.is_action_pressed('left'):
		velocity.x = velocity.x * friction
		if velocity.x < 0.05 and velocity.x > -0.05:
			velocity.x = 0
	
	# move left or right and deal with wall jumps
	if Input.is_action_pressed('right'):
		direction = RIGHT
		
		# hacky solution to make it so the sprite doesn't flip when wall jumping
		# may remove I don't know if it's needed or not
		if just_wall_jumped:
			direction = LEFT
		
		if velocity.x < speed:
			velocity.x += speed
		else:
			velocity.x = speed
		
		walking = true
			
	if Input.is_action_pressed('left'):
		direction = LEFT
		
		if just_wall_jumped:
			direction = RIGHT
		
		if velocity.x > speed * -1:
			velocity.x -= speed
		else:
			velocity.x = speed * -1
		
		walking = true

# control the direction the player is facing depending on cursor location
# and fix the positioning of the hitbox and face/light sprites
func handle_direction():
	if direction == LEFT:
		body.flip_h = true
		lucky_lights.position.x = -4
		lucky_lights_body.position.x = -2
		$Body.get_node("Lights/Numbers").position.x = 0
		bullet_start.position.x = 4
		hitbox.position.x = -1
	else:
		body.flip_h = false
		lucky_lights.position.x = 0
		lucky_lights_body.position.x = 1
		$Body.get_node("Lights/Numbers").position.x = 0
		bullet_start.position.x = 4
		hitbox.position.x = 0
		
#	if get_global_mouse_position() < position:
#		$Body.flip_h = true
#		$Body.get_node("Lights/Lucky").position.x = -4
#		$Body.get_node("Lights/Numbers").position.x = -4
#		$Hitbox.position.x = -1
#	else:
#		$Body.flip_h = false
#		$Body.get_node("Lights/Lucky").position.x = 0
#		$Body.get_node("Lights/Numbers").position.x = 0
#		$Hitbox.position.x = 0

# control the sprites animation
func animate_sprite():
	# play walking when walking
	if walking and $Body.animation != 'walking':
		body.play('walking')
		
	if velocity.x == 0:
		walking = false
		if body.animation != 'idle':
			body.play('idle')
	
	# wall_sliding
	if is_on_wall() and not is_on_floor():
		if direction == LEFT:
			body.flip_h = false
			lucky_lights.position.x = 0
			lucky_lights_body.position.x = 1
			$Body.get_node("Lights/Numbers").position.x = 0
			bullet_start.position.x = 0
			hitbox.position.x = 0		

		else:
			body.flip_h = true
			lucky_lights.position.x = -4
			$Body.get_node("Lights/Numbers").position.x = -4
			lucky_lights_body.position.x = -2
			bullet_start.position.x = 4
			hitbox.position.x = -1

		body.play('wall_slide')
	
	# jumping
	if not is_on_wall() and not is_on_floor():
		if direction == RIGHT:
			body.flip_h = false
			lucky_lights.position.x = 0
			$Body.get_node("Lights/Numbers").position.x = 0
			$Hitbox.position.x = 0

		else:
			body.flip_h = true
			lucky_lights.position.x = -4
			$Body.get_node("Lights/Numbers").position.x = -4
			hitbox.position.x = -1	
		
		body.play('wall_slide')

# allows the player to jump
func jump():
	# allow for a jump if we are on the ground or on the wall
	if Input.is_action_just_pressed('jump') and is_on_floor() or Input.is_action_just_pressed('jump') and is_on_wall():
		# set it so we're jumping
		jumping = true	
		velocity.y = jump_speed * -1
	
		# check for wall jumps and apply the wall jump power to velocity.x
		if not is_on_floor() and is_on_wall() and $RightDetector.is_colliding():
			just_wall_jumped = true
			$WallJumpTimer.start()
			velocity.x -= wall_jump_speed
			
		elif not is_on_floor() and is_on_wall() and $LeftDetector.is_colliding():
			just_wall_jumped = true
			$WallJumpTimer.start()
			velocity.x += wall_jump_speed

	# allow for variable jump heights (stop jumping when jump key is released)
	if Input.is_action_just_released('jump') and velocity.y < 0:
		velocity.y = 0

# check if the tile below us is a spike and take damage if needed
func check_for_spikes():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		var cell = tiles.world_to_map(collision.position - collision.normal)
		var tile_id = tiles.get_cellv(cell)	
		if tile_id == 1:
			damaged = true
			take_damage()
			
# check if damage has been taken
func check_for_damage():
	# check for a spike
	check_for_spikes()
	
	# see if an enemy has entered the hurtbox
	for area in hurtbox.get_overlapping_areas():
		if area.is_in_group("enemy"):
			damaged = true
			var hit_obj = area.get_parent()
			var incoming_pos = hit_obj.position
			take_damage()
			# destroy enemy bullets when hit
			if hit_obj.has_method("destroy"):
				hit_obj.destroy()
			
# take damage and temporary freeze/screenshake when damage is taken	
func take_damage():
	damaged = true
	get_parent().get_node("Camera2D").add_trauma(0.3)
	$FreezeTimer.start()
	get_tree().paused = true
	
func change_weapon(weapon):
	curr_weapon = weapon
	if curr_weapon == Weapons.DEFAULT:
		$ShootTimer.wait_time = 0.8
		
func shoot():
	if Input.is_action_pressed("shoot") and can_shoot:
		print("HERE")	
		can_shoot = false
		$ShootTimer.start()
		if curr_weapon == Weapons.DEFAULT:
			print(position, bullet_start.position)
			print(bullet_start.position, " ", bullet_start.global_position)
			var new_bullet = small_bullet.instance()
			new_bullet.setup(bullet_start.global_position.direction_to(get_global_mouse_position()), bullet_start.global_position)
			get_parent().add_child(new_bullet)

# idle movement when starting
func _ready():
	$Body.play('idle')
	
func _physics_process(delta):
	# check for damaged if there are no i-frames
	if not damaged:
		check_for_damage()
	
	# if damaged and the damage timer hasn't stared, start it and the
	# damage flash timer to begin i-frames
	if damaged and $DamageTimer.time_left == 0:
		$DamageTimer.start()
		$DamageFlashTimer.start()
	
	# make sure the sprite is facing the right way
	handle_direction()
	
	# get the user's left/right input
	get_input()
	
	# deal with animation
	animate_sprite()
	
	# deal with shooting
	shoot()
	
	# apply graivity and clamp it so it maxes out at max gravity
	if velocity.y < max_gravity:
		velocity.y += gravity
	if velocity.y > max_gravity:
		velocity.y = max_gravity
	
	# move the player
	move_and_slide(velocity, Vector2.UP)
	
	# check for jumps
	jump()
	
	# stop jumping logic if we're on the floor or wall
	if is_on_floor() or is_on_wall() and velocity.y >= 0:
		jumping = false
		just_wall_jumped = false
	
	# fall down if we hit the ceiling
	if is_on_ceiling():
		velocity.y = 100
	
	# slide down the wall to make it easier to wall jump
	if is_on_wall() and not is_on_floor() and velocity.y >= 0:
		velocity.y = 50

# for wall jumping animation
func _on_WallJumpTimer_timeout():
	just_wall_jumped = false

# when i-frames are over, make damaged false and remove flash
func _on_DamageTimer_timeout():
	body.modulate.a = 255
	$DamageFlashTimer.stop()
	damaged = false

# while in i-frames, make sprite flash
func _on_DamageFlashTimer_timeout():
	if body.modulate.a == 0.5:
		body.modulate.a = 0.3
	else:
		body.modulate.a = 0.5

# stops the temporary freeze after getting damaged
func _on_FreezeTimer_timeout():
	get_tree().paused = false


func _on_ShootTimer_timeout():
	can_shoot = true
