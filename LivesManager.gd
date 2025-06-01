# LivesManager.gd - Add this as an Autoload singleton
extends Node

signal lives_changed(new_lives)
signal game_over

var max_lives = 3
var current_lives = 3

func _ready():
	reset_lives()
	# Connect to our own game_over signal to handle scene reloading
	game_over.connect(_on_game_over)

func reset_lives():
	current_lives = max_lives
	lives_changed.emit(current_lives)
	# DON'T reset checkpoints here - checkpoints should persist through deaths

func lose_life():
	current_lives -= 1
	lives_changed.emit(current_lives)
	
	if current_lives <= 0:
		game_over.emit()
		return false  # Game over
	return true  # Still has lives

# Separate function to handle game over logic
func _on_game_over():
	# Add a small delay before reloading to let other systems process the game over
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

func get_lives():
	return current_lives

func has_lives():
	return current_lives > 0

# Call this only when starting a completely new game (not after game over)
func start_new_game():
	reset_lives()
	CheckpointManager.reset_checkpoint()  # Only reset checkpoints for new game
