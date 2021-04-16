extends KinematicBody2D

export var speed = 150

var velocity = Vector2.ZERO

func setup(vel, pos):
	velocity = vel
	global_position = pos

func _process(delta):
	if not get_tree().paused:
		var collision = move_and_collide(speed * velocity * delta)
		if collision:
			destroy()
		
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()

func destroy():
	$AnimatedSprite.play()

func _on_AnimatedSprite_animation_finished():
	queue_free()
