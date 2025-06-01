# CheckpointManager.gd - Add this as an Autoload singleton
extends Node

var default_spawn_position = Vector2(0, 0)
var current_checkpoint_position = Vector2.ZERO
var current_checkpoint_set = false
var active_checkpoint_id = ""

# Save checkpoint data to a file so it persists across scene reloads
const CHECKPOINT_SAVE_PATH = "user://checkpoint_data.save"

func _ready():
	load_checkpoint_data()

func save_checkpoint_data():
	var save_file = FileAccess.open(CHECKPOINT_SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"current_checkpoint_position_x": current_checkpoint_position.x,
			"current_checkpoint_position_y": current_checkpoint_position.y,
			"current_checkpoint_set": current_checkpoint_set,
			"active_checkpoint_id": active_checkpoint_id
		}
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("Saved checkpoint data: ", save_data)

func load_checkpoint_data():
	if FileAccess.file_exists(CHECKPOINT_SAVE_PATH):
		var save_file = FileAccess.open(CHECKPOINT_SAVE_PATH, FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var save_data = json.data
				
				# FIXED: Load Vector2 components separately to avoid string conversion issues
				var pos_x = save_data.get("current_checkpoint_position_x", 0.0)
				var pos_y = save_data.get("current_checkpoint_position_y", 0.0)
				current_checkpoint_position = Vector2(pos_x, pos_y)
				
				current_checkpoint_set = save_data.get("current_checkpoint_set", false)
				active_checkpoint_id = save_data.get("active_checkpoint_id", "")
				print("Loaded checkpoint data: ", save_data)
				print("Reconstructed checkpoint position: ", current_checkpoint_position)
			else:
				print("Failed to parse checkpoint JSON data")
	else:
		print("No checkpoint save file found")

func set_checkpoint(position: Vector2, checkpoint_id: String = ""):
	current_checkpoint_position = position
	current_checkpoint_set = true
	active_checkpoint_id = checkpoint_id
	save_checkpoint_data()  # Save immediately when checkpoint is set
	print("✓ Checkpoint saved: ", checkpoint_id, " at ", position)

func get_respawn_position() -> Vector2:
	if current_checkpoint_set:
		print("Respawning at checkpoint: ", current_checkpoint_position)
		return current_checkpoint_position
	else:
		print("Respawning at default spawn: ", default_spawn_position)
		return default_spawn_position

func reset_checkpoint():
	current_checkpoint_set = false
	current_checkpoint_position = Vector2.ZERO
	active_checkpoint_id = ""
	save_checkpoint_data()  # Save the reset state
	print("All checkpoints reset")

# Call this function to clear corrupted save data
func clear_save_data():
	if FileAccess.file_exists(CHECKPOINT_SAVE_PATH):
		DirAccess.remove_absolute(CHECKPOINT_SAVE_PATH)
		print("Cleared corrupted checkpoint save data")
	reset_checkpoint()

func set_default_spawn(pos: Vector2):
	default_spawn_position = pos
	print("Default spawn set to: ", pos)

# FIXED: This function was overriding checkpoints
func initialize_level(spawn_pos: Vector2):
	set_default_spawn(spawn_pos)
	# Only set current checkpoint position if NO checkpoint is currently set
	if not current_checkpoint_set:
		current_checkpoint_position = spawn_pos

func get_active_checkpoint_id() -> String:
	return active_checkpoint_id

# Debug function
func print_status():
	print("=== CheckpointManager Status ===")
	print("Default spawn: ", default_spawn_position)
	print("Current checkpoint: ", current_checkpoint_position)
	print("Checkpoint set: ", current_checkpoint_set)
	print("Active ID: ", active_checkpoint_id)
