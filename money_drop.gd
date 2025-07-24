extends RigidBody2D

@export var money_value: int = 10
@export var drop_size: float = 15.0

signal collected(value)

func _ready():
	# Create money bag sprite based on value
	create_money_sprite()
	
	# Set up collision
	var collision = $MoneyCollision
	var shape = CircleShape2D.new()
	shape.radius = drop_size
	collision.shape = shape
	
	# Set physics properties - slower falling
	gravity_scale = 0.3
	linear_damp = 2.0
	
	# Connect collision detection
	body_entered.connect(_on_body_entered)
	
	# Auto-destroy after 10 seconds if not collected
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func create_money_sprite():
	# Remove the existing sprite if it exists
	if has_node("MoneySprite"):
		$MoneySprite.queue_free()
	
	# Create a sprite with programmatic money image
	var sprite = Sprite2D.new()
	sprite.name = "MoneySprite"
	
	var image_size = int(drop_size * 2)
	var image = Image.create(image_size, image_size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Choose image based on money value
	if money_value >= 50:
		create_money_bag_image(image, image_size)
	elif money_value >= 25:
		create_dollar_bill_image(image, image_size)
	else:
		create_coin_image(image, image_size)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	sprite.texture = texture
	
	add_child(sprite)

func create_money_bag_image(image: Image, size: int):
	var center = size / 2
	var bag_color = Color(0.6, 0.4, 0.2)  # Brown
	var string_color = Color(0.8, 0.7, 0.4)  # Gold
	
	# Draw money bag (rounded rectangle)
	for x in range(size):
		for y in range(int(size * 0.3), size):
			var dx = x - center
			var dy = y - center
			var distance = sqrt(dx * dx + dy * dy)
			if distance < center * 0.8:
				image.set_pixel(x, y, bag_color)
	
	# Draw bag opening (top part)
	for x in range(int(size * 0.3), int(size * 0.7)):
		for y in range(int(size * 0.2), int(size * 0.35)):
			image.set_pixel(x, y, string_color)
	
	# Draw dollar sign
	var dollar_color = Color.WHITE
	for y in range(int(size * 0.4), int(size * 0.8)):
		image.set_pixel(center, y, dollar_color)
	for x in range(int(size * 0.3), int(size * 0.7)):
		if x != center:
			image.set_pixel(x, int(size * 0.5), dollar_color)
			image.set_pixel(x, int(size * 0.65), dollar_color)

func create_dollar_bill_image(image: Image, size: int):
	var bill_color = Color(0.2, 0.6, 0.2)  # Green
	var text_color = Color.WHITE
	
	# Draw bill rectangle
	for x in range(int(size * 0.1), int(size * 0.9)):
		for y in range(int(size * 0.2), int(size * 0.8)):
			image.set_pixel(x, y, bill_color)
	
	# Draw border
	var border_color = Color(0.1, 0.3, 0.1)
	for x in range(int(size * 0.1), int(size * 0.9)):
		image.set_pixel(x, int(size * 0.2), border_color)
		image.set_pixel(x, int(size * 0.8) - 1, border_color)
	for y in range(int(size * 0.2), int(size * 0.8)):
		image.set_pixel(int(size * 0.1), y, border_color)
		image.set_pixel(int(size * 0.9) - 1, y, border_color)
	
	# Draw dollar sign
	var center = size / 2
	for y in range(int(size * 0.3), int(size * 0.7)):
		image.set_pixel(center, y, text_color)
	for x in range(int(size * 0.35), int(size * 0.65)):
		if x != center:
			image.set_pixel(x, int(size * 0.4), text_color)
			image.set_pixel(x, int(size * 0.6), text_color)

func create_coin_image(image: Image, size: int):
	var center = size / 2
	var coin_color = Color(1.0, 0.8, 0.2)  # Gold
	var edge_color = Color(0.8, 0.6, 0.1)  # Darker gold
	
	# Draw coin circle
	for x in range(size):
		for y in range(size):
			var dx = x - center
			var dy = y - center
			var distance = sqrt(dx * dx + dy * dy)
			if distance < center * 0.8:
				if distance > center * 0.7:
					image.set_pixel(x, y, edge_color)  # Edge
				else:
					image.set_pixel(x, y, coin_color)  # Center
	
	# Draw dollar sign
	var text_color = Color(0.6, 0.4, 0.0)  # Dark gold
	for y in range(int(size * 0.3), int(size * 0.7)):
		image.set_pixel(center, y, text_color)
	for x in range(int(size * 0.35), int(size * 0.65)):
		if x != center:
			image.set_pixel(x, int(size * 0.4), text_color)
			image.set_pixel(x, int(size * 0.6), text_color)

func setup_money_drop(value: int, position: Vector2):
	money_value = value
	global_position = position
	
	# Adjust size based on value
	if value >= 50:
		drop_size = 20.0
	elif value >= 25:
		drop_size = 17.0
	else:
		drop_size = 15.0
	
	create_money_sprite()

func _on_body_entered(body):
	# Check if the colliding body is the paddle
	if is_paddle(body):
		# Collected by paddle from any direction
		collected.emit(money_value)
		MoneyManager.add_money(money_value)
		queue_free()

func is_paddle(body) -> bool:
	# Multiple ways to detect if this is the paddle
	
	# Method 1: Check if it has paddle script
	if body.has_method("get_script"):
		var script = body.get_script()
		if script and script.get_path().get_file() == "paddle.gd":
			return true
	
	# Method 2: Check if it's a CharacterBody2D with paddle properties
	if body is CharacterBody2D and body.has_method("has_method"):
		if body.has_method("_physics_process") and body.get("paddle_width"):
			return true
	
	# Method 3: Check node name (fallback)
	if body.name.to_lower().contains("paddle"):
		return true
	
	# Method 4: Check if it has paddle-specific properties
	if body.get("speed") != null and body.get("paddle_width") != null:
		return true
	
	return false
