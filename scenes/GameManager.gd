# GameManager.gd
extends Node

# Character scenes
@export var player_scene: PackedScene
@export var monster_scene: PackedScene

# BGM settings
@export var player_bgm: AudioStream
@export var monster_bgm: AudioStream

# Current state
var current_character = "player"
var current_instance = null
@onready var bgm_player = $BGMPlayer

func _ready():
	# Create BGM player if it doesn't exist
	if !has_node("BGMPlayer"):
		var audio_player = AudioStreamPlayer.new()
		audio_player.name = "BGMPlayer"
		audio_player.bus = "Master"  # Or use "Music" if you have that bus
		add_child(audio_player)
		bgm_player = audio_player
	
	# Find and connect all monster heads in the scene
	connect_monster_heads()

func connect_monster_heads():
	# Find all monster heads in the level
	var monster_heads = get_tree().get_nodes_in_group("transform_area")
	
	# Connect their signals
	for head in monster_heads:
		if head.has_signal("player_transform_triggered"):
			if !head.player_transform_triggered.is_connected(transform_to_monster):
				head.player_transform_triggered.connect(transform_to_monster)

func transform_to_monster():
	if current_character != "monster":
		transform_character("monster")

func transform_to_player():
	if current_character != "player":
		transform_character("player")

func transform_character(new_character: String):
	if new_character == current_character:
		return
	
	# Get current position and velocity
	var current_position = Vector2.ZERO
	var current_velocity = Vector2.ZERO
	
	if current_instance:
		current_position = current_instance.global_position
		current_velocity = current_instance.velocity
		current_instance.queue_free()
	
	# Instantiate new character
	var scene_to_spawn = null
	var bgm_to_play = null
	
	match new_character:
		"player":
			scene_to_spawn = player_scene
			bgm_to_play = player_bgm
		"monster":
			scene_to_spawn = monster_scene
			bgm_to_play = monster_bgm
	
	if scene_to_spawn:
		var instance = scene_to_spawn.instantiate()
		get_tree().current_scene.add_child(instance)
		
		# Position at the same spot
		instance.global_position = current_position
		instance.velocity = current_velocity
		
		# Make sure the new character is in the player group
		if !instance.is_in_group("player"):
			instance.add_to_group("player")
		
		# Update references
		current_instance = instance
		current_character = new_character
		
		# Update BGM
		if bgm_to_play and bgm_player:
			bgm_player.stream = bgm_to_play
			if bgm_player.playing:
				# Fade between tracks (optional)
				var tween = create_tween()
				tween.tween_property(bgm_player, "volume_db", -40, 0.5)
				tween.tween_callback(func(): 
					bgm_player.stream = bgm_to_play
					bgm_player.volume_db = -40
					bgm_player.play()
				)
				tween.tween_property(bgm_player, "volume_db", 0, 0.5)
			else:
				bgm_player.play()
