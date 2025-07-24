extends StaticBody2D

@export var brick_width = 80.0
@export var brick_height = 30.0
@export var brick_color = Color.RED

# Don't export these - they should only be set by setup_brick()
var hits_required = 1
var money_value = 10

signal destroyed
signal money_dropped(amount, pos)

var current_hits = 0

func _ready():
	# Set up collision shape first
	var collision = $BrickCollision
	var shape = RectangleShape2D.new()
	shape.size = Vector2(brick_width, brick_height)
	collision.shape = shape
	
	# Add bouncy physics material
	var brick_material = PhysicsMaterial.new()
	brick_material.bounce = 1.0
	brick_material.friction = 0.0
	physics_material_override = brick_material
	
	# Don't call update_brick_appearance here - wait for setup_brick()

func update_brick_appearance():
	# Create a colored rectangle for the brick
	var sprite = $BrickSprite
	var texture = ImageTexture.new()
	var image = Image.create(int(brick_width), int(brick_height), false, Image.FORMAT_RGB8)
	
	# Darken brick based on damage taken
	var damage_factor = float(current_hits) / float(hits_required)
	var current_color = brick_color.lerp(Color.BLACK, damage_factor * 0.5)
	image.fill(current_color)
	
	# Add cracks if damaged
	if current_hits > 0 and hits_required > 1:
		add_cracks_to_image(image, damage_factor)
	
	texture.set_image(image)
	sprite.texture = texture

func add_cracks_to_image(image: Image, damage_factor: float):
	var width = int(brick_width)
	var height = int(brick_height)
	
	# Add some simple crack lines
	if damage_factor > 0.3:
		# Horizontal crack
		for x in range(width):
			if x % 3 == 0:  # Sparse crack
				image.set_pixel(x, height / 2, Color.DARK_GRAY)
	
	if damage_factor > 0.6:
		# Vertical crack
		for y in range(height):
			if y % 2 == 0:  # Sparse crack
				image.set_pixel(width / 2, y, Color.DARK_GRAY)

func hit():
	current_hits += 1
	
	if current_hits >= hits_required:
		# Brick is destroyed - drop money
		money_dropped.emit(money_value, global_position)
		destroyed.emit()
		queue_free()
	else:
		# Brick is damaged but not destroyed - update appearance
		update_brick_appearance()

func setup_brick(color: Color, hits: int, money: int):
	brick_color = color
	hits_required = hits
	money_value = money
	current_hits = 0
	update_brick_appearance()