extends RigidBody2D

@export var base_ball_speed = 300.0
@export var ball_radius = 10.0

signal brick_hit(brick)
signal life_lost
signal paddle_hit
signal ball_launched

var has_fallen = false
var current_speed = 0.0
var speed_multiplier = 1.0
var is_waiting_for_launch = false

func _ready():
	# Calculate speed based on screen resolution for consistent gameplay
	var screen_size = get_viewport().get_visible_rect().size
	var resolution_factor = screen_size.length() / Vector2(1152, 648).length()  # Reference resolution
	current_speed = base_ball_speed * resolution_factor
	
	# Create a simple white circle for the ball
	var sprite = $BallSprite
	var texture = ImageTexture.new()
	var image = Image.create(int(ball_radius * 2), int(ball_radius * 2), false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Draw a better circle with anti-aliasing
	for x in range(int(ball_radius * 2)):
		for y in range(int(ball_radius * 2)):
			var distance = Vector2(x - ball_radius, y - ball_radius).length()
			if distance <= ball_radius - 1:
				image.set_pixel(x, y, Color.WHITE)
			elif distance <= ball_radius:
				var alpha = 1.0 - (distance - (ball_radius - 1))
				image.set_pixel(x, y, Color(1, 1, 1, alpha))
	
	texture.set_image(image)
	sprite.texture = texture
	
	# Set up collision shape
	var collision = $BallCollision
	var shape = CircleShape2D.new()
	shape.radius = ball_radius
	collision.shape = shape
	
	# Set physics properties
	gravity_scale = 0
	linear_damp = 0
	angular_damp = 0
	var ball_material = PhysicsMaterial.new()
	ball_material.bounce = 1.0
	ball_material.friction = 0.0
	physics_material_override = ball_material
	
	# Connect to collision signal
	contact_monitor = true
	max_contacts_reported = 10
	body_entered.connect(_on_body_entered)
	
func start_ball():
	# Reset all states
	has_fallen = false
	is_waiting_for_launch = false
	speed_multiplier = 1.0
	freeze = false
	# Start the ball moving at an angle
	var start_velocity = Vector2(randf_range(-1, 1), -1).normalized() * get_current_speed()
	linear_velocity = start_velocity
	ball_launched.emit()

func reset_for_new_life():
	# Reset the ball for a new life, positioned above paddle
	has_fallen = false
	is_waiting_for_launch = true
	speed_multiplier = 1.0
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
	# Always position above paddle center
	var screen_size = get_viewport().get_visible_rect().size
	global_position = Vector2(screen_size.x / 2, screen_size.y - 100)

func get_current_speed() -> float:
	return current_speed * speed_multiplier

func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit()
		brick_hit.emit(body)
	else:
		# Check if this is likely a paddle collision (near bottom of screen)
		var screen_size = get_viewport().get_visible_rect().size
		if position.y > screen_size.y * 0.8:  # In bottom 20% of screen
			# Detected paddle collision - increase speed by 20%
			speed_multiplier *= 1.20
			paddle_hit.emit()
	
func _physics_process(_delta):
	# Handle waiting for launch
	if is_waiting_for_launch:
		if Input.is_action_just_pressed("click") or Input.is_action_just_pressed("ui_accept"):
			start_ball()
		return
	
	# Check if ball went off screen bottom
	if position.y > get_viewport().get_visible_rect().size.y + 50 and not has_fallen:
		has_fallen = true
		# Stop the ball immediately and prepare for reset
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		freeze = true
		life_lost.emit()
		return
	
	# Keep ball speed constant at current level (only if not fallen)
	if not has_fallen and linear_velocity.length() > 0:
		linear_velocity = linear_velocity.normalized() * get_current_speed()