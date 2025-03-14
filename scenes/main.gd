# Main.gd (attach to your main scene)
extends Node2D

@onready var game_manager = get_node("GameManager")

func _ready():
	# Set up game manager with scene references
	game_manager.player_scene = preload("res://scenes/Character.tscn")
	game_manager.monster_scene = preload("res://scenes/monster.tscn")
	game_manager.player_bgm = preload("res://assets/assets_sound_bgm.wav")
	game_manager.monster_bgm = preload("res://assets/monster_bgm.ogg")
	
	# Start with player character if none exists
	if game_manager.current_instance == null:
		var player = game_manager.player_scene.instantiate()
		add_child(player)
		player.add_to_group("player")
		game_manager.current_instance = player
		game_manager.current_character = "player"
		
		# Start player BGM
		game_manager.bgm_player.stream = game_manager.player_bgm
		game_manager.bgm_player.play()
	
	# Connect monster heads
	game_manager.connect_monster_heads()
