extends "res://items_old/item.gd"

func mb(_item):
	$animation.play("mb")
	$animation.speed_scale = dexterity

func atack():
	#grid.set_cell_item(round($mesh/atack.get_global_position()), -1)
	$mesh/atack.monitorable = false

func area():
	$mesh/atack.monitorable = true
