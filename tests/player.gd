extends CharacterBody3D

#structure
@export var carton = 10
@export var head_health = 10
@export var body_health = 10
@export var energy = 10

#stats
var speed = 8
var vitality = 10
var dexterity = 1

#vars
var acc = 10
var jump = 50
var wall_jumps = 1
var stamina = 0
var mouse_focus = true
var input_dir
var direction

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$kinematic/camera/ray.add_exception(self)

func _physics_process(delta):
	if head_health > 0:
		#direction
		input_dir = Input.get_vector("a", "d", "w", "s")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, $kinematic.rotation.y)
		
		#jump
		if Input.is_action_pressed("ui_accept") and is_on_floor():
			velocity.y = jump/acc
			stamina = wall_jumps
	else: direction = Vector2()
	
	#move
	if is_on_floor():
		if direction:
			velocity.x = move_toward(velocity.x, speed*direction.x, abs(direction.x)*speed/acc)
			velocity.z = move_toward(velocity.z, speed*direction.z, abs(direction.z)*speed/acc)
		velocity.x = move_toward(velocity.x, 0, abs(velocity.x)/acc)
		velocity.z = move_toward(velocity.z, 0, abs(velocity.z)/acc)
	elif direction:
		velocity.x = move_toward(velocity.x, speed*direction.x, abs(direction.x)/acc)
		velocity.z = move_toward(velocity.z, speed*direction.z, abs(direction.z)/acc)
	
	#gravity
	if !is_on_floor():
		velocity.y -= gravity*delta
	
	#crouch
	if !$ray.is_colliding():
		if Input.is_action_pressed("ctrl") or Input.is_action_pressed("shift") or head_health < 1:
			jump = 0
			$collision.rotation.y = $kinematic.rotation.y
			$collision.rotation_degrees.x = move_toward($collision.rotation_degrees.x, -65, 6)
			$kinematic/body.rotation_degrees.x = move_toward($collision.rotation_degrees.x, -65, 6)
			$kinematic/camera.global_position = $kinematic/body/camera.global_position
			$head.global_position = $kinematic/camera.global_position
		else:
			$kinematic/body.rotation_degrees.x = move_toward($kinematic/body.rotation_degrees.x, 0, 6)
			$kinematic/camera.global_transform.origin = $kinematic/body/camera.global_transform.origin
	
	#black_screen
	if $screen/black.color.a > 0: $screen/black.color.a -= 0.01
	
	move_and_slide()

func _input(event):
	if head_health > 0:
		#mouse
		if event is InputEventMouseMotion:
			$kinematic.rotate_y(-event.relative.x * .001)
			$kinematic/camera.rotate_x(-event.relative.y * .001)
			#$kinematic/camera.rotation.x = clamp($kinematic/camera.rotation.x, -PI/2, PI/2)
		
			if $kinematic/camera/ray.is_colliding():
				$kinematic/body/lh.look_at($kinematic/camera/ray.get_collision_point())
				$kinematic/body/rh.look_at($kinematic/camera/ray.get_collision_point())
			else:
				$kinematic/body/lh.rotation.x = $kinematic/camera.rotation.x
				$kinematic/body/rh.rotation.x = $kinematic/camera.rotation.x
				$kinematic/body/lh.rotation.y = 0
				$kinematic/body/rh.rotation.y = 0
		
		#mouse_button
		if mouse_focus:
			if Input.is_action_just_pressed("lmb") and $kinematic/body/lh.get_child_count():
				$kinematic/body/lh.get_child(0).dexterity = dexterity
				$kinematic/body/lh.get_child(0).mb($kinematic/body/rh.get_child(0))
			if Input.is_action_just_pressed("rmb") and $kinematic/body/rh.get_child_count():
				$kinematic/body/rh.get_child(0).dexterity = dexterity
				$kinematic/body/rh.get_child(0).mb($kinematic/body/lh.get_child(0))
			
			#energy_label
			if $kinematic/body/lh.get_child(0): $screen/control/lh/label.text = $kinematic/body/lh.get_child(0).name + " = " + str($kinematic/body/lh.get_child(0).get("energy"))
			else: $screen/control/lh/label.text = ""
			if $kinematic/body/rh.get_child(0): $screen/control/rh/label.text = $kinematic/body/rh.get_child(0).name + " = " + str($kinematic/body/rh.get_child(0).get("energy"))
			else: $screen/control/rh/label.text = ""
		
		#wall_jump
		if Input.is_action_just_pressed("ui_accept") and is_on_wall() and stamina > 0:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			velocity.y = jump/acc
			stamina -= 1
		
		#up
		if !$ray.is_colliding():
			if !Input.is_action_pressed("ctrl") and !Input.is_action_pressed("shift"):
				jump = 50
				$collision.rotation_degrees.y = 0
				$collision.rotation_degrees.x = 0
				$head.position = Vector3(0, 1, 0)
	
	if Input.is_action_just_pressed("f11"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

#hit
func _on_body_area_area_entered(area):
	if carton > 0: carton -= area.damage
	else: body_health -= area.damage
	$screen/black.color.a = 0.4

func _on_head_area_area_entered(area):
	if carton > 0: carton -= area.damage
	else: head_health -= area.damage
	$screen/black.color.a = 0.8
