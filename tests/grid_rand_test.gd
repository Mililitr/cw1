extends GridMap

func _ready():
	for x in range(50):
		for z in range(50):
			for y in range(50):
				y = randi()%50
				set_cell_item(Vector3(x, y, z), 0, 0)
