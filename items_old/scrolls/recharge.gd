extends "res://items_old/item.gd"

var energy = 0

signal item_recharge(energy)

func _ready():
	energy = randi_range(1, 10)

func mb(item):
	if item.get("energy") >= 0:
		item_recharge.emit(energy)
