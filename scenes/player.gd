extends CharacterBody2D

# --- BASIC MOVEMENT ---
@export var gravity           = 200.0
@export var walk_speed        = 200.0
@export var jump_speed        = -300.0

# --- DOUBLE JUMP ---
var jump_count                = 0
var max_jumps                 = 2  # 2 means normal jump + 1 extra jump

# --- DASH (double-tap left/right) ---
@export var dash_speed        = 600.0
@export var dash_duration     = 0.2
var dash_timer                = 0.0
var dashing_direction         = 0

var last_left_tap_time        = 0
var last_right_tap_time       = 0
@export var double_tap_threshold_ms = 200

# --- CROUCH ---
@export var crouch_speed_factor   = 0.5
@export var normal_shape_size     = Vector2(48, 64)
@export var crouch_shape_size     = Vector2(48, 32)

var is_crouching             = false


func _physics_process(delta: float) -> void:
	# grav
	velocity.y += gravity * delta

	# --- Reset jump count if on floor ---
	if is_on_floor():
		jump_count = 0

	# double jump
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_speed
			jump_count = 1
		elif jump_count < max_jumps:
			velocity.y = jump_speed
			jump_count += 1

	# detech dash
	if Input.is_action_just_pressed("ui_left"):
		var now = Time.get_ticks_msec()
		if (now - last_left_tap_time) < double_tap_threshold_ms:
			dash_timer = dash_duration
			dashing_direction = -1
		last_left_tap_time = now

	if Input.is_action_just_pressed("ui_right"):
		var now = Time.get_ticks_msec()
		if (now - last_right_tap_time) < double_tap_threshold_ms:
			dash_timer = dash_duration
			dashing_direction = 1
		last_right_tap_time = now

	# apply dash
	if dash_timer > 0:
		velocity.x = dashing_direction * dash_speed
		dash_timer -= delta
	else:
		if Input.is_action_pressed("ui_left"):
			velocity.x = -walk_speed
		elif Input.is_action_pressed("ui_right"):
			velocity.x = walk_speed
		else:
			velocity.x = 0

	# crouch
	if Input.is_action_pressed("ui_down"):
		is_crouching = true
	else:
		is_crouching = false

	# Adjust collision shape if crouching
	var shape = $CollisionShape2D.shape as RectangleShape2D
	if is_crouching:
		velocity.x *= crouch_speed_factor
		shape.size = crouch_shape_size
	else:
		shape.size = normal_shape_size

   
	move_and_slide()
