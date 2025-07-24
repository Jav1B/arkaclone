extends Node2D

var paddle_scene = preload("res://paddle.tscn")
var ball_scene = preload("res://ball.tscn")
var brick_scene = preload("res://brick.tscn")

var paddle
var ball
var bricks = []
var score = 0
var lives = 3

@onready var score_label = $UI/ScoreLabel
@onready var lives_label = $UI/LivesLabel
@onready var game_over_label = $UI/GameOverLabel

func _ready():
	create_boundaries()
	setup_game()

func create_boundaries():
	# Create invisible walls around the screen
	var screen_size = get_viewport().get_visible_rect().size
	
	# Create bouncy physics material for walls
	var wall_material = PhysicsMaterial.new()
	wall_material.bounce = 1.0
	wall_material.friction = 0.0
	
	# Top wall
	var top_wall = StaticBody2D.new()
	var top_collision = CollisionShape2D.new()
	var top_shape = RectangleShape2D.new()
	top_shape.size = Vector2(screen_size.x, 20)
	top_collision.shape = top_shape
	top_wall.add_child(top_collision)
	top_wall.position = Vector2(screen_size.x / 2, -10)
	top_wall.physics_material_override = wall_material
	add_child(top_wall)
	
	# Left wall
	var left_wall = StaticBody2D.new()
	var left_collision = CollisionShape2D.new()
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(20, screen_size.y)
	left_collision.shape = left_shape
	left_wall.add_child(left_collision)
	left_wall.position = Vector2(-10, screen_size.y / 2)
	left_wall.physics_material_override = wall_material
	add_child(left_wall)
	
	# Right wall
	var right_wall = StaticBody2D.new()
	var right_collision = CollisionShape2D.new()
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(20, screen_size.y)
	right_collision.shape = right_shape
	right_wall.add_child(right_collision)
	right_wall.position = Vector2(screen_size.x + 10, screen_size.y / 2)
	right_wall.physics_material_override = wall_material
	add_child(right_wall)

func setup_game():
	var screen_size = get_viewport().get_visible_rect().size
	
	# Create paddle
	paddle = paddle_scene.instantiate()
	paddle.position = Vector2(screen_size.x / 2, screen_size.y - 50)
	add_child(paddle)
	
	# Create ball
	ball = ball_scene.instantiate()
	ball.position = Vector2(screen_size.x / 2, screen_size.y / 2)
	ball.brick_hit.connect(_on_brick_hit)
	ball.game_over.connect(_on_game_over)
	add_child(ball)
	
	# Create bricks
	create_bricks()
	
	# Start ball after a short delay
	await get_tree().create_timer(1.0).timeout
	ball.start_ball()

func create_bricks():
	var screen_size = get_viewport().get_visible_rect().size
	var brick_width = 80.0
	var brick_height = 30.0
	var padding = 5.0
	var rows = 6
	var cols = int(screen_size.x / (brick_width + padding))
	
	var colors = [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.BLUE, Color.PURPLE]
	
	for row in range(rows):
		for col in range(cols):
			var brick = brick_scene.instantiate()
			brick.brick_color = colors[row % colors.size()]
			brick.position = Vector2(
				col * (brick_width + padding) + brick_width / 2 + padding,
				row * (brick_height + padding) + brick_height / 2 + 50
			)
			brick.destroyed.connect(_on_brick_destroyed)
			bricks.append(brick)
			add_child(brick)

func _on_brick_hit(_brick):
	score += 10

func _on_brick_destroyed():
	score += 10
	update_ui()
	
	# Check if all bricks are destroyed
	var remaining_bricks = get_children().filter(func(child): return child.has_method("hit"))
	if remaining_bricks.size() == 0:
		game_won()

func _on_game_over():
	lives -= 1
	update_ui()
	
	if lives <= 0:
		game_over_label.text = "GAME OVER!\nTap to restart"
		game_over_label.visible = true
	else:
		# Reset ball position
		ball.position = Vector2(get_viewport().get_visible_rect().size.x / 2, get_viewport().get_visible_rect().size.y / 2)
		ball.linear_velocity = Vector2.ZERO
		await get_tree().create_timer(1.0).timeout
		ball.start_ball()

func game_won():
	game_over_label.text = "YOU WIN!\nTap to restart"
	game_over_label.visible = true

func update_ui():
	score_label.text = "Score: " + str(score)
	lives_label.text = "Lives: " + str(lives)

func _input(event):
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("click")) and game_over_label.visible:
		get_tree().reload_current_scene()