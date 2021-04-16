extends KinematicBody2D

export var speed := 600

enum {LEFT, RIGHT}

var rng := RandomNumberGenerator.new()

var direction := LEFT

var velocity := Vector2(0, 300)

onready var tiles := get_parent().get_node("Tiles")

var last_pos := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
#	direction = rng.randi_range(0, 1)
	direction = LEFT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# flip direction if hit a wall
	if position == last_pos:
		if direction == LEFT:
			direction = RIGHT
		else:
			direction = LEFT
	last_pos = position
	
	if not $RightCheck.is_colliding():
		direction = LEFT
	elif not $LeftCheck.is_colliding():
		direction = RIGHT	
	
	if direction == LEFT:
		velocity.x = speed * -1
	
	elif direction == RIGHT:
		velocity.x = speed
		
	if direction == RIGHT:
		$AnimatedSprite.flip_h = false
	elif direction == LEFT:
		$AnimatedSprite.flip_h = true

	var collision = move_and_collide(velocity * delta)
	
	
