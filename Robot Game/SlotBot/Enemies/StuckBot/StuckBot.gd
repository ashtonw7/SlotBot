extends AnimatedSprite

enum {IDLE, SHOOTING}

var state = IDLE

var bullet = preload("res://Enemies/Bullets/SmallBullet/SmallBullet.tscn")

var bullet_pos1 = Vector2.ZERO
var bullet_pos2 = Vector2.ZERO

var vel1 = Vector2.RIGHT
var vel2 = Vector2.LEFT

var velocity = Vector2(50, 50)

func _ready():
	if rotation != 0:
		vel1 = Vector2.UP
		vel2 = Vector2.DOWN
	
	if rotation == 0:
		bullet_pos1.x = global_position.x + 8
		bullet_pos2.x = global_position.x - 8
		bullet_pos1.y = global_position.y - 4
		bullet_pos2.y = global_position.y - 4
	
	$ShootTimer.start()

func _process(delta):
	if state == IDLE and animation != "idle":
		play("idle")
	elif state == SHOOTING and animation != "shooting":
		play("shooting")

func _on_ShootTimer_timeout():
	state = SHOOTING
	$PostShotTimer.start()
	
	var bullet_1 = bullet.instance()
	var bullet_2 = bullet.instance()
	
	bullet_1.setup(vel1, bullet_pos1)
	bullet_2.setup(vel2, bullet_pos2)
	
	get_parent().add_child(bullet_1)
	get_parent().add_child(bullet_2)

func _on_PostShotTimer_timeout():
	state = IDLE
	$ShootTimer.start()
