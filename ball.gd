extends RigidBody2D

@export var ball_speed = 300.0
@export var ball_radius = 10.0

signal brick_hit(brick)
signal life_lost

var has_fallen = false

func _ready():
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
	# Reset the fallen state
	has_fallen = false
	# Start the ball moving at an angle
	var start_velocity = Vector2(randf_range(-1, 1), -1).normalized() * ball_speed
	linear_velocity = start_velocity

func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit()
		brick_hit.emit(body)
	
func _physics_process(_delta):
	# Check if ball went off screen bottom
	if position.y > get_viewport().get_visible_rect().size.y + 50 and not has_fallen:
		has_fallen = true
		life_lost.emit()
	
	# Keep ball speed constant
	if linear_velocity.length() > 0:
		linear_velocity = linear_velocity.normalized() * ball_speed