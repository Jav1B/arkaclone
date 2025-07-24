extends Control

@onready var title_label = $MenuContainer/TitleLabel
@onready var start_button = $MenuContainer/StartButton
@onready var money_display = $MoneyDisplay
@onready var fireworks_left = $FireworksLeft
@onready var fireworks_right = $FireworksRight

var tween: Tween

func _ready():
	# Set up the title
	title_label.text = "MIERDOLO"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color.YELLOW)
	title_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	title_label.add_theme_constant_override("shadow_offset_x", 4)
	title_label.add_theme_constant_override("shadow_offset_y", 4)
	
	# Set up the start button
	start_button.text = "START GAME"
	start_button.add_theme_font_size_override("font_size", 32)
	start_button.custom_minimum_size = Vector2(200, 60)
	
	# Center the menu container
	var menu_container = $MenuContainer
	menu_container.anchors_preset = Control.PRESET_CENTER
	menu_container.anchor_left = 0.5
	menu_container.anchor_right = 0.5
	menu_container.anchor_top = 0.5
	menu_container.anchor_bottom = 0.5
	menu_container.offset_left = -150
	menu_container.offset_right = 150
	menu_container.offset_top = -100
	menu_container.offset_bottom = 100
	menu_container.add_theme_constant_override("separation", 40)
	
	# Set up fireworks
	setup_fireworks()
	
	# Set up money display
	money_display.text = "Money: $" + str(MoneyManager.get_money())
	money_display.add_theme_font_size_override("font_size", 24)
	money_display.add_theme_color_override("font_color", Color.GOLD)
	money_display.anchors_preset = Control.PRESET_TOP_RIGHT
	money_display.anchor_left = 1.0
	money_display.anchor_right = 1.0
	money_display.offset_left = -150
	money_display.offset_right = -10
	money_display.offset_bottom = 30
	
	# Connect signals
	start_button.pressed.connect(_on_start_pressed)
	MoneyManager.money_changed.connect(_on_money_changed)
	
	# Start title animation
	animate_title()

func setup_fireworks():
	var screen_size = get_viewport().get_visible_rect().size
	
	# Position fireworks
	fireworks_left.position = Vector2(screen_size.x * 0.2, screen_size.y * 0.3)
	fireworks_right.position = Vector2(screen_size.x * 0.8, screen_size.y * 0.3)
	
	# Configure left fireworks
	setup_firework_particles(fireworks_left, Color.RED)
	
	# Configure right fireworks
	setup_firework_particles(fireworks_right, Color.BLUE)
	
	# Start fireworks
	fireworks_left.emitting = true
	fireworks_right.emitting = true

func setup_firework_particles(particles: GPUParticles2D, color: Color):
	var material = ParticleProcessMaterial.new()
	
	# Basic emission
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 150.0
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0
	
	# Gravity and damping
	material.gravity = Vector3(0, 98, 0)
	material.linear_accel_min = -20.0
	material.linear_accel_max = 20.0
	
	# Scale
	material.scale_min = 0.5
	material.scale_max = 2.0
	
	# Color
	material.color = color
	material.color_ramp = create_color_ramp()
	
	particles.process_material = material
	particles.amount = 100
	particles.lifetime = 3.0
	particles.explosiveness = 0.8

func create_color_ramp() -> Gradient:
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE, Color.YELLOW, Color.TRANSPARENT])
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	return gradient

func animate_title():
	tween = create_tween()
	tween.set_loops()
	tween.tween_method(update_title_scale, 1.0, 1.2, 1.0)
	tween.tween_method(update_title_scale, 1.2, 1.0, 1.0)

func update_title_scale(scale: float):
	title_label.scale = Vector2(scale, scale)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_money_changed(new_amount: int):
	money_display.text = "Money: $" + str(new_amount)

func _input(event):
	# Handle touch/click to start game
	if event.is_action_pressed("click"):
		var button_rect = start_button.get_global_rect()
		var click_pos = event.position if event is InputEventMouseButton else get_global_mouse_position()
		
		if button_rect.has_point(click_pos):
			_on_start_pressed()