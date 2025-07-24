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
	# Don't reset values here that might be set by setup_brick()

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
	
	# Update the hit counter label
	var label = $HitCountLabel
	var remaining_hits = hits_required - current_hits
	label.text = str(remaining_hits)
	
	# Make the text more visible based on brick color
	if current_color.get_luminance() > 0.5:
		label.modulate = Color.BLACK
	else:
		label.modulate = Color.WHITE

func add_cracks_to_image(image: Image, damage_factor: float):
	var width = int(brick_width)
	var height = int(brick_height)
	var crack_color = Color.BLACK
	var light_crack_color = Color.DARK_GRAY
	
	# Progressive crack system based on damage
	if damage_factor > 0.1:  # Light cracks appear early
		add_hairline_cracks(image, width, height, light_crack_color)
	
	if damage_factor > 0.4:  # Medium cracks
		add_branching_cracks(image, width, height, light_crack_color)
	
	if damage_factor > 0.7:  # Heavy cracks
		add_deep_cracks(image, width, height, crack_color)
		add_corner_damage(image, width, height, crack_color)

func add_hairline_cracks(image: Image, width: int, height: int, color: Color):
	# Small random cracks scattered across the brick
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("hairline") + current_hits
	
	for i in range(3):
		var start_x = rng.randi_range(5, width - 5)
		var start_y = rng.randi_range(2, height - 2)
		var length = rng.randi_range(8, 15)
		var direction = rng.randf() * 2 * PI
		
		for j in range(length):
			var x = start_x + int(cos(direction) * j * 0.7)
			var y = start_y + int(sin(direction) * j * 0.3)
			if x >= 0 and x < width and y >= 0 and y < height:
				image.set_pixel(x, y, color)

func add_branching_cracks(image: Image, width: int, height: int, color: Color):
	# Main crack line with small branches
	var center_y = height / 2
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("branching") + current_hits
	
	# Main horizontal crack with variation
	for x in range(10, width - 10):
		var y_offset = rng.randi_range(-2, 2)
		var crack_y = center_y + y_offset
		if crack_y >= 0 and crack_y < height:
			image.set_pixel(x, crack_y, color)
			
			# Add small vertical branches occasionally
			if x % 8 == 0:
				var branch_length = rng.randi_range(2, 5)
				var branch_dir = 1 if rng.randf() > 0.5 else -1
				for b in range(branch_length):
					var branch_y = crack_y + (b * branch_dir)
					if branch_y >= 0 and branch_y < height:
						image.set_pixel(x, branch_y, color)

func add_deep_cracks(image: Image, width: int, height: int, color: Color):
	# Thick, prominent cracks indicating severe damage
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("deep") + current_hits
	
	# Diagonal crack from corner
	var start_corner = rng.randi_range(0, 3)  # 0=top-left, 1=top-right, 2=bottom-left, 3=bottom-right
	var start_x = 0 if start_corner < 2 else width - 1
	var start_y = 0 if start_corner % 2 == 0 else height - 1
	var end_x = width - 1 - start_x
	var end_y = height - 1 - start_y
	
	var steps = max(abs(end_x - start_x), abs(end_y - start_y))
	for i in range(steps):
		var progress = float(i) / float(steps)
		var x = start_x + int((end_x - start_x) * progress)
		var y = start_y + int((end_y - start_y) * progress)
		
		# Make crack thicker by drawing multiple pixels
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var px = x + dx
				var py = y + dy
				if px >= 0 and px < width and py >= 0 and py < height:
					if dx == 0 or dy == 0:  # Cross pattern for thickness
						image.set_pixel(px, py, color)

func add_corner_damage(image: Image, width: int, height: int, color: Color):
	# Damaged/chipped corners
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("corner") + current_hits
	
	var corners = [
		Vector2(0, 0), Vector2(width-1, 0), 
		Vector2(0, height-1), Vector2(width-1, height-1)
	]
	
	for corner in corners:
		if rng.randf() > 0.5:  # Only damage some corners
			var damage_size = rng.randi_range(2, 4)
			for x in range(damage_size):
				for y in range(damage_size):
					var px = corner.x + (x if corner.x == 0 else -x)
					var py = corner.y + (y if corner.y == 0 else -y)
					if px >= 0 and px < width and py >= 0 and py < height:
						if rng.randf() > 0.3:  # Irregular damage
							image.set_pixel(px, py, color)

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