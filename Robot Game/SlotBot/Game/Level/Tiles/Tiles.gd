extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var damage_tile = 1
var damaging_tiles = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for cell in get_used_cells():
		if get_cell(cell[0], cell[1]) == 1:
			damaging_tiles.append(cell)
#	print(damaging_tiles)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
