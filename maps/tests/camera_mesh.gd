extends Camera3D

func _physics_process(delta):
	$"../look".look_at($"../player_test".position)
	rotation.y = lerp_angle(rotation.y, $"../look".rotation.y, 0.05)
	rotation.x = lerp_angle(rotation.x, $"../look".rotation.x, 0.05)

func _input(event):
	if Input.is_action_just_pressed("f"):
		#$"../player/kinematic/camera".current = !$"../player/kinematic/camera".current
		current = !current
