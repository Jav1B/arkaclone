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
	
	# Set physics properties
	gravity_scale = 1.0
	linear_damp = 0.5
	
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
	var sprite = $MoneySprite
	var texture = ImageTexture.new()
	var size = int(drop_size * 2)
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Choose color and symbol based on money value
	var bag_color: Color
	var symbol: String
	
	if money_value >= 50:
		bag_color = Color.GOLD
		symbol = "$$$"
	elif money_value >= 25:
		bag_color = Color.YELLOW
		symbol = "$$"
	else:
		bag_color = Color.GREEN
		symbol = "$"
	
	# Draw money bag (simple circle with $ symbol effect)
	var center = Vector2(size / 2, size / 2)
	for x in range(size):
		for y in range(size):
			var pos = Vector2(x, y)
			var distance = pos.distance_to(center)
			
			if distance <= drop_size - 2:
				image.set_pixel(x, y, bag_color)
			elif distance <= drop_size:
				image.set_pixel(x, y, bag_color.darkened(0.3))
		
	texture.set_image(image)
	sprite.texture = texture

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
	# Check if collected by paddle (in bottom area of screen)
	var screen_size = get_viewport().get_visible_rect().size
	if position.y > screen_size.y * 0.7:  # In bottom 30% of screen
		collected.emit(money_value)
		MoneyManager.add_money(money_value)
		queue_free()