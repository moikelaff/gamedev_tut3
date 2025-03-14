extends CharacterBody2D

# --- MOVEMENT PARAMETERS ---
@export_group("Movement")
@export var gravity = 200.0
@export var walk_speed = 300.0
@export var jump_speed = -300.0
@export var crouch_speed_factor = 0.5

# --- JUMP PARAMETERS ---
@export_group("Jump")
@export var max_jumps = 2  # Normal jump + extra jump
var jump_count = 0

# --- DASH PARAMETERS ---
@export_group("Dash")
@export var dash_speed = 600.0
@export var dash_duration = 0.2
@export var double_tap_threshold_ms = 200
var dash_timer = 0.0
var dashing_direction = 0
var last_left_tap_time = 0
var last_right_tap_time = 0

# --- COLLISION SHAPES ---
@export_group("Collision")
@export var normal_shape_size = Vector2(48, 64)
@export var crouch_shape_size = Vector2(48, 32)
var is_crouching = false

# --- COMPONENTS ---
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D.shape as RectangleShape2D
@onready var camera = $Camera2D

# --- AUDIO ---
@export_group("Audio")
@export var bgm_player: AudioStreamPlayer
@export var jump_sound: AudioStreamPlayer
@export var dash_sound: AudioStreamPlayer

func _ready() -> void:
	# Ensure the camera is active
	if !has_node("Camera2D"):
		var new_camera = Camera2D.new()
		new_camera.name = "Camera2D"
		add_child(new_camera)
		camera = new_camera
	
	camera.make_current()
	
	# Start playing background music if available
	if bgm_player and bgm_player.stream:
		bgm_player.play()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_dash(delta)
	handle_movement()
	handle_crouch()
	move_and_slide()
	update_animation()

func apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta
	
	# Reset jump count if on floor
	if is_on_floor():
		jump_count = 0

func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_up") and jump_count < max_jumps:
		velocity.y = jump_speed
		jump_count += 1
		
		# Play jump sound if available
		if jump_sound:
			jump_sound.play()

func handle_dash(delta: float) -> void:
	# Check for double tap left
	if Input.is_action_just_pressed("ui_left"):
		var now = Time.get_ticks_msec()
		if (now - last_left_tap_time) < double_tap_threshold_ms:
			start_dash(-1)
		last_left_tap_time = now
	
	# Check for double tap right
	if Input.is_action_just_pressed("ui_right"):
		var now = Time.get_ticks_msec()
		if (now - last_right_tap_time) < double_tap_threshold_ms:
			start_dash(1)
		last_right_tap_time = now
	
	# Apply dash
	if dash_timer > 0:
		velocity.x = dashing_direction * dash_speed
		dash_timer -= delta
	
func start_dash(direction: int) -> void:
	dash_timer = dash_duration
	dashing_direction = direction
	
	# Play dash sound if available
	if dash_sound:
		dash_sound.play()

func handle_movement() -> void:
	# Only control movement if not dashing
	if dash_timer <= 0:
		if Input.is_action_pressed("ui_left"):
			velocity.x = -walk_speed
			animated_sprite.flip_h = true
		elif Input.is_action_pressed("ui_right"):
			velocity.x = walk_speed
			animated_sprite.flip_h = false
		else:
			velocity.x = 0

func handle_crouch() -> void:
	var was_crouching = is_crouching
	
	# Update crouching state
	is_crouching = Input.is_action_pressed("ui_down") and is_on_floor()
	
	# Only update collision shape if state changed
	if is_crouching != was_crouching:
		collision_shape.size = crouch_shape_size if is_crouching else normal_shape_size
		
	# Apply speed reduction when crouching
	if is_crouching:
		velocity.x *= crouch_speed_factor

func update_animation() -> void:
	var new_anim = "idle"
	
	# Animation priority
	if dash_timer > 0:
		new_anim = "dash"
	elif !is_on_floor():
		new_anim = "jump"
	elif is_crouching:
		new_anim = "crouch"
	elif abs(velocity.x) > 10:  # Small threshold to prevent flickering
		new_anim = "walk"
	
	play_animation(new_anim)

func play_animation(anim_name: String) -> void:
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)
