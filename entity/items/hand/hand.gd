extends "res://entity/items/item.gd"

func mb():
	$animation.play("mb")
	$animation.speed_scale = 1 + dexterity/10 - 0.1

func atack():
	$mesh/atack/collision.disabled = !$mesh/atack/collision.disabled

func _on_atack_area_entered(area):
	if area.get("hit"): area.hit.emit(damage)

func _on_atack_body_entered(body):
	if body is RigidBody3D:
		body.apply_central_impulse((body.global_position - $mesh/atack/collision.global_position)*10)
		body.apply_torque_impulse((body.global_position - $mesh/atack/collision.global_position))
