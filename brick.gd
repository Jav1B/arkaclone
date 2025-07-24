extends StaticBody2D

@export var brick_width = 80.0
@export var brick_height = 30.0
@export var brick_color = Color.RED

signal destroyed

func _ready():
	# Create a colored rectangle for the brick
	var sprite = $BrickSprite
	var texture = ImageTexture.new()
	var image = Image.create(int(brick_width), int(brick_height), false, Image.FORMAT_RGB8)
	image.fill(brick_color)
	texture.set_image(image)
	sprite.texture = texture
	
	# Set up collision shape
	var collision = $BrickCollision
	var shape = RectangleShape2D.new()
	shape.size = Vector2(brick_width, brick_height)
	collision.shape = shape
	
	# Add bouncy physics material
	var brick_material = PhysicsMaterial.new()
	brick_material.bounce = 1.0
	brick_material.friction = 0.0
	physics_material_override = brick_material

func hit():
	destroyed.emit()
	queue_free()