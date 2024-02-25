extends CharacterBody3D

#structure
@export var carton = 20
@export var head_health = 20
@export var body_health = 20
@export var energy = true

@onready var lh = $neck/lh
@onready var rh = $neck/rh
@onready var camera_ray = $kinematic/camera/ray

#stats
@export var self_speed = 8
@export var self_dexterity = 1
@export var self_strength = 1
@export var self_velocity = 100

#vars
var speed = self_speed
var jump = 5
var wall_jumps = 1
var stamina = 0
var input_dir
var direction

#settings
var sensitive = 0.8
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var effect_scene = preload("res://commands/effect/effect.tscn")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_ray.add_exception(self)
	$screen/control/structure/hbox/carton_label.text = str(carton) + "%"
	$screen/control/structure/hbox/head_health_label.text = str(head_health) + "%"
	$screen/control/structure/hbox/body_health_label.text = str(body_health) + "%"

func _physics_process(delta):
	#move
	if is_on_floor():
		if direction:
			velocity.x = move_toward(velocity.x, speed*direction.x, abs(direction.x)*speed/10)
			velocity.z = move_toward(velocity.z, speed*direction.z, abs(direction.z)*speed/10)
		velocity.x = move_toward(velocity.x, 0, abs(velocity.x)/10)
		velocity.z = move_toward(velocity.z, 0, abs(velocity.z)/10)
	elif direction:
		velocity.x = move_toward(velocity.x, speed*direction.x, abs(direction.x)/8)
		velocity.z = move_toward(velocity.z, speed*direction.z, abs(direction.z)/8)
	
	#gravity
	if !is_on_floor(): velocity.y -= gravity*delta
	
	move_and_slide()
	
	#death
	if head_health <= 0:
		#crouch
		$tree["parameters/blend_position"] = lerp($tree["parameters/blend_position"], -1.0, float(speed)/80)
		
		direction = Vector2()
		return
	
	#direction
	input_dir = Input.get_vector("a", "d", "w", "s")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, $kinematic.rotation.y)
	
	#mouse_button
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_pressed("lmb") and lh.get_child_count():
			lh.get_child(0).dexterity = self_dexterity
			lh.get_child(0).damage = self_strength
			lh.get_child(0).mb()
		if Input.is_action_pressed("rmb") and rh.get_child_count():
			rh.get_child(0).dexterity = self_dexterity
			rh.get_child(0).damage = self_strength
			rh.get_child(0).mb()
	
	#body_rotation
	$neck.rotation.y = lerp_angle($neck.rotation.y, $kinematic.rotation.y, float(speed)/40)
	
	#jump
	if Input.is_action_pressed("space") and is_on_floor():
		velocity.y = jump
		if energy: stamina = wall_jumps
	
	#crouch
	if Input.is_action_pressed("ctrl") or Input.is_action_pressed("shift"):
		$tree["parameters/blend_position"] = lerp($tree["parameters/blend_position"], -1.0, float(speed)/80)
		jump = 0
	#stand_up
	elif !$ray.is_colliding():
		$tree["parameters/blend_position"] = lerp($tree["parameters/blend_position"], 1.0, float(speed)/80)
		jump = 5
	#hands_look_at
	if camera_ray.is_colliding():
				lh.look_at(camera_ray.get_collision_point(), Vector3.UP)
				rh.look_at(camera_ray.get_collision_point(), Vector3.UP)
	else:
		lh.look_at($kinematic/camera/ray/ray_end.global_position)
		rh.look_at($kinematic/camera/ray/ray_end.global_position)
	
	#black_screen
	if $screen/black.color.a > 0: $screen/black.color.a -= 0.01

func _input(event):
	#death
	if head_health <= 0: return
	
	#mouse
	if event is InputEventMouseMotion:
		
		$kinematic.rotate_y(-event.relative.x * .001 * sensitive)
		$kinematic/camera.rotate_x(-event.relative.y * .001 * sensitive)
		$kinematic/camera.rotation.x = clamp($kinematic/camera.rotation.x, -PI/2, PI/2)
		
		#energy_label
		if lh.get_child(0): $screen/control/lh/label.text = lh.get_child(0).name + " = " + str(lh.get_child(0).get("energy"))
		else: $screen/control/lh/label.text = ""
		if rh.get_child(0): $screen/control/rh/label.text = rh.get_child(0).name + " = " + str(rh.get_child(0).get("energy"))
		else: $screen/control/rh/label.text = ""
	
	if event is InputEventKey:
		#wall_jump
		if Input.is_action_just_pressed("space") and is_on_wall() and stamina > 0:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			velocity.y = jump
			stamina -= 1
		
		#drop_item
		if Input.is_action_just_pressed("1") and lh.get_child_count():
			lh.get_child(0).freeze = false
			lh.get_child(0).reparent(get_parent())
		if Input.is_action_just_pressed("3") and rh.get_child_count():
			rh.get_child(0).freeze = false
			rh.get_child(0).reparent(get_parent())
		
		if Input.is_action_just_pressed("f11"):
			if !DisplayServer.window_get_mode(): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

#head_hit
func _on_head_hit(_damage = 0):
	$screen/black.color.a = 0.8
	
	#hit
	randomize()
	if carton > 0:
		if randi()%carton == randi()%carton:
			carton = 0;
		else:
			carton -= randi()%_damage + 1
			if carton < 0: head_health += carton
	elif head_health > 0:
		if randi()%head_health == randi()%head_health:
			head_health = 0;
		else: head_health -= randi()%_damage + 1
	$screen/control/structure/hbox/carton_label.text = str(carton) + "%"
	$screen/control/structure/hbox/head_health_label.text = str(head_health) + "%"
#	for i in range(_damage):
#		if carton > 0: carton -= 1
#		elif head_health > 0: head_health -= 1
#	for i in range(10):
#		if i >= carton: $screen/structure/grid/carton/hbox.get_child(i).visible = false
#		if i >= head_health: $screen/structure/grid/head_health/hbox.get_child(i).visible = false
#	print(carton, _damage)

#body_hit
func _on_body_hit(_damage = 0):
	$screen/black.color.a = 0.4
	
	#hit
	randomize()
	if carton > 0:
		if randi()%carton == randi()%carton:
			carton = 0;
		else:
			carton -= randi()%_damage + 1
			if carton < 0: body_health += carton
	elif body_health > 0:
		if randi()%body_health == randi()%body_health:
			body_health = 0;
		else: body_health -= randi()%_damage + 1
	$screen/control/structure/hbox/carton_label.text = str(carton) + "%"
	$screen/control/structure/hbox/body_health_label.text = str(body_health) + "%"
	
	#effect_slowness
	if body_health <= 0:
		effect(1, 666)
#	for i in range(_damage):
#		if carton > 0: carton -= 1
#		elif body_health > 0: body_health -= 1
#	for i in range(10):
#		if i >= carton: $screen/structure/grid/carton/hbox.get_child(i).visible = false
#		if i >= body_health: $screen/structure/grid/body_health/hbox.get_child(i).visible = false

#effect
func effect(id = 0, time = 10):
	var effect_instance = effect_scene.instantiate()
	if time != 666: effect_instance.wait_time = time
	else: effect_instance.infinity = true
	effect_instance.id = id
	add_child(effect_instance)
	match id:
		1, "slowness":
			speed /= 1.4

#effect_timeout
func effect_timeout(id = 0):
	match id:
		1, "slowness":
			speed = self_speed
