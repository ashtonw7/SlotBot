extends KinematicBody2D

export var speed = 100
export var vertical_speed = 50

enum {LEFT, RIGHT}
enum States {CHARGING, ATTACKING}

var left_boundary = 9
var right_boundary = 349

var direction = RIGHT

var state = States.CHARGING

var velocity = Vector2.ZERO

var just_moved = false

onready var body = $Body
onready var eyes = $Eyes
onready var hitbox = $Hitbox.get_node("CollisionShape2D")

onready var player = get_parent().get_node("Robot")

func _ready():
	$ChargingTimer.start()

func _process(delta):
	if eyes.frame == 2:
		eyes.stop()
		
	if $ChargingTimer.time_left < 1 and not eyes.playing:
		eyes.play()
	
	if state == States.ATTACKING and floor(position.x) == left_boundary and velocity.x < 0:
		velocity = Vector2.ZERO
		state = States.CHARGING
		if $ChargingTimer.time_left == 0:
			$ChargingTimer.start()

		direction = LEFT
		body.flip_h = true
		eyes.flip_h = true
		eyes.position.x = 3
		hitbox.position.x = -4
		
		
		just_moved = true
		
		eyes.stop()
		eyes.frame = 0
		
	elif state == States.ATTACKING and floor(position.x) == right_boundary and velocity.x > 0:
		velocity = Vector2.ZERO
		state = States.CHARGING
		if $ChargingTimer.time_left == 0:
			$ChargingTimer.start()
			
		direction = RIGHT
		body.flip_h = false
		eyes.flip_h = false
		eyes.position.x = -2
		hitbox.position.x = 4
		
		just_moved = true
		
		eyes.stop()
		eyes.frame = 0		

	if state == States.CHARGING:
		var player_pos = player.position.y
		var pos = position.y
		var pos_diff = abs(player_pos) - abs(pos)
		
		if player_pos > pos:
			if abs(pos_diff) > 10 and just_moved:
				velocity.y = vertical_speed * 2
			else:
				velocity.y = vertical_speed
				just_moved = false
			
		elif player_pos < pos:
			if abs(pos_diff) > 10 and just_moved:
				velocity.y = vertical_speed * -2
			else:
				velocity.y = vertical_speed * -1
				just_moved = false
			
		if body.animation != "charging":
			body.play("charging")
		move_and_collide(velocity * delta)
			
	elif state == States.ATTACKING:
		velocity = Vector2.ZERO
		if direction == RIGHT:
			velocity.x = speed * -1
		else:
			velocity.x = speed
		move_and_collide(velocity * delta)

func _on_ChargingTimer_timeout():
	state = States.ATTACKING
	body.play("attacking")
	
