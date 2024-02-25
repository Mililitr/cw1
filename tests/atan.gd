extends Node3D

@onready var aim = $"../aim"

func _ready():
	$"../a".current_animation = "new_animation"
	

func _physics_process(delta):
	rotation.y = atan2(position.x - aim.position.x, position.z - aim.position.z)
#	look_at(aim.position)
#	rotation.y = atan2(-aim.position.x, -aim.position.z);
