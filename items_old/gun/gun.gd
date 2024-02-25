extends "res://items_old/item.gd"

var energy = 0

func mb(item):
	if item.get("item_recharge"):
		item.item_recharge.connect(recharge, Object.ConnectFlags.CONNECT_ONE_SHOT)
	
	if energy > 0 and $animation.current_animation == "":
		$animation.play("atack")

func atack():
	energy -= 1

func recharge(e):
	energy += e
