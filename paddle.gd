extends CharacterBody2D

@export var speed = 400.0
@export var paddle_width = 100.0

func _ready():
	# Create a simple white rectangle for the paddle
	var sprite = $PaddleSprite
	var texture = ImageTexture.new()
	var image = Image.create(int(paddle_width), 20, false, Image.FORMAT_RGB8)
	image.fill(Color.WHITE)
	texture.set_image(image)
	sprite.texture = texture
	
	# Set up collision shape
	var collision = $PaddleCollision
	var shape = RectangleShape2D.new()
	shape.size = Vector2(paddle_width, 20)
	collision.shape = shape
	
	# CharacterBody2D doesn't use physics_material_override

func _physics_process(_delta):
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
	
	move_and_slide()
	
	# Keep paddle within screen bounds
	var screen_size = get_viewport().get_visible_rect().size
	position.x = clamp(position.x, paddle_width/2, screen_size.x - paddle_width/2)