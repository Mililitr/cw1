extends Timer

var id = 0
var infinity = false

func _on_timeout():
	if !infinity:
		get_parent().effect_timeout(id)
		queue_free()
