# MonsterHead.gd
extends Area2D

signal player_transform_triggered

func _ready():
	# Add to transform_area group
	add_to_group("transform_area")
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if it's the player character
	if body.is_in_group("player"):
		# Emit signal that player touched the monster head
		player_transform_triggered.emit()
		# Optionally, make the monster head disappear
		queue_free()
