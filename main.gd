extends Node2D

var paddle_scene = preload("res://paddle.tscn")
var ball_scene = preload("res://ball.tscn")
var brick_scene = preload("res://brick.tscn")
var money_drop_scene = preload("res://money_drop.tscn")

var paddle
var ball
var bricks = []
var score = 0
var lives = 3

@onready var score_label = $UI/ScoreLabel
@onready var lives_label = $UI/LivesLabel
@onready var money_label = $UI/MoneyLabel
@onready var launch_label = $UI/LaunchLabel
@onready var game_over_label = $UI/GameOverLabel

func _ready():
	create_boundaries()
	setup_game()
	
	# Connect to money system
	MoneyManager.money_changed.connect(_on_money_changed)
	
	# Connect to ball state changes
	ball.ball_launched.connect(_on_ball_launched)
	
	update_ui()
	show_launch_instruction()

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
	ball.life_lost.connect(_on_life_lost)
	add_child(ball)
	
	# Create bricks
	create_bricks()
	
	# Set ball to waiting state at start
	ball.reset_for_new_life()

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
			
			# Progressive difficulty: each row deeper requires one more hit and gives more money
			var hits_required = row + 1  # Row 0 = 1 hit, Row 1 = 2 hits, etc.
			var money_value = (row + 1) * 10  # Row 0 = $10, Row 1 = $20, Row 2 = $30, etc.
			
			# Set up brick completely before adding to scene
			brick.setup_brick(colors[row % colors.size()], hits_required, money_value)
			brick.position = Vector2(
				col * (brick_width + padding) + brick_width / 2 + padding,
				row * (brick_height + padding) + brick_height / 2 + 50
			)
			
			# Connect signals and add to scene
			brick.destroyed.connect(_on_brick_destroyed)
			brick.money_dropped.connect(_on_money_dropped)
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

func _on_life_lost():
	lives -= 1
	update_ui()
	
	if lives <= 0:
		game_over_label.text = "GAME OVER!\nTap to return to menu"
		game_over_label.visible = true
	else:
		# Reset ball position and restart immediately
		await get_tree().process_frame  # Wait one frame for physics to settle
		reset_ball()

func game_won():
	game_over_label.text = "YOU WIN!\nTap to return to menu"
	game_over_label.visible = true

func reset_ball():
	ball.reset_for_new_life()
	show_launch_instruction()

func show_launch_instruction():
	launch_label.text = "TAP TO LAUNCH BALL"
	launch_label.visible = true

func _on_ball_launched():
	launch_label.visible = false

func update_ui():
	score_label.text = "Score: " + str(score)
	lives_label.text = "Lives: " + str(lives)
	money_label.text = "Money: $" + str(MoneyManager.get_money())

func _on_money_changed(new_amount: int):
	money_label.text = "Money: $" + str(new_amount)

func _on_money_dropped(amount: int, pos: Vector2):
	var money_drop = money_drop_scene.instantiate()
	money_drop.setup_money_drop(amount, pos)
	add_child(money_drop)

func _input(event):
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("click")) and game_over_label.visible:
		get_tree().change_scene_to_file("res://main_menu.tscn")