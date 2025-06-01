extends Node2D

@onready var player = $Player

func _ready():
	# Wait one frame for physics to initialize
	call_deferred("set_player_position")

func set_player_position():
	# Set position ONCE, not twice
	player.global_position = Vector2(217, 1)
	player.velocity = Vector2.ZERO
	
	# Force sprite visibility
	var sprite = player.get_node("AnimatedSprite2D")
	if sprite:
		sprite.visible = true
		sprite.modulate = Color.WHITE
		sprite.play("idle")
		print("Sprite forced visible")
	else:
		print("ERROR: Could not find AnimatedSprite2D node!")
	
	print("Player spawned at: ", player.global_position)
	
	# Debug gravity and physics
	print("Player gravity: ", player.gravity if "gravity" in player else "No gravity property")
	print("Player velocity: ", player.velocity)
	print("Project gravity: ", ProjectSettings.get_setting("physics_2d/default_gravity"))

func _process(delta):
	# Print player status every second
	if Engine.get_process_frames() % 60 == 0:
		print("Player pos: ", player.global_position, " vel: ", player.velocity)
