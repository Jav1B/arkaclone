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
	# Remove the sprite2D and add a label with emoji instead
	if has_node("MoneySprite"):
		$MoneySprite.queue_free()
	
	# Create a label with money emoji
	var label = Label.new()
	label.name = "MoneyLabel"
	
	# Choose emoji based on money value
	if money_value >= 50:
		label.text = "💰"  # Money bag
		label.add_theme_font_size_override("font_size", 24)
	elif money_value >= 25:
		label.text = "💵"  # Dollar bill
		label.add_theme_font_size_override("font_size", 20)
	else:
		label.text = "🪙"  # Coin
		label.add_theme_font_size_override("font_size", 16)
	
	# Center the label
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(-drop_size, -drop_size)
	label.size = Vector2(drop_size * 2, drop_size * 2)
	
	add_child(label)

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