extends Spatial


# Character's movement speed in m/s.
export(float) var movement_speed = 5.0

# Give this big of a push when jumping. In m/s.
export(float) var jump_power = 10.0

# Gravity in m * s^(-2). Positive = pull down.
export(float) var gravity = 9.8

export(float) var mouse_sensitivity = 0.02

var velocity = Vector3.ZERO

onready var body = $Body

onready var camera = $Body/Camera


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		var rotation = event.relative * mouse_sensitivity
		body.rotate_y(-rotation.x)
		camera.rotate_x(-rotation.y)
		
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2.0, PI / 2.0)


func _physics_process(delta):
	velocity.y -= gravity * delta
	
	# Give absolutely no control when mid-air.
	if body.is_on_floor():
		var horizontal = get_horizontal_movement()
		velocity.x = horizontal.x
		velocity.z = horizontal.y
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_power
	
	velocity = body.move_and_slide(velocity, Vector3.UP)


func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		body.translation = Vector3.ZERO
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit(0)


# Return movement in the XZ plane.
func get_horizontal_movement():
	var horizontal = Vector2.ZERO
	
	if Input.is_action_pressed("move_forwards"):
		# Forwards is negative Z.
		horizontal.y -= movement_speed
	
	if Input.is_action_pressed("move_backwards"):
		horizontal.y += movement_speed
	
	if Input.is_action_pressed("move_left"):
		horizontal.x -= movement_speed
	
	if Input.is_action_pressed("move_right"):
		horizontal.x += movement_speed
	
	# Ensure proper alignment.
	horizontal = horizontal.rotated(-body.rotation.y)
	
	return horizontal
