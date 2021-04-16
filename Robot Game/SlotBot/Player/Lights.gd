extends Node2D

# adjust the position of the face/light based on the animation frame
func _process(delta):
	if get_parent().frame % 2 == 0:
		position.y = 0
	else:
		position.y = 1
