extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	# Check if it's the player
	if body.name == "Player":
		print("You died!")
		
		# Slow down game engine (keep this effect if you like it)
		#Engine.time_scale = 0.5
		
		# Instead of destroying collision and reloading scene,
		# use the new lives system
		if body.has_method("take_damage"):
			body.take_damage()
		
		# Start timer to restore normal time scale
		timer.start()

func _on_timer_timeout():
	# Restore normal time scale
	Engine.time_scale = 1
	
	# Remove the scene reload - lives system handles respawning now
	# get_tree().reload_current_scene()  # <- OLD CODE (commented out)
	
	# Optional: Add any other cleanup or effects here
