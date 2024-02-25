extends Node2D

func _physics_process(delta):
	$Icon.position = get_global_mouse_position()
	$r.look_at($Icon.position)
	$Face.rotation = lerp($Face.rotation, $r.rotation, 0.05)
	$Face.position += Vector2(cos($Face.rotation), sin($Face.rotation))
#	$Face.rotation = move_toward($Face.rotation, $r.rotation, 0.1)
