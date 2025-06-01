extends Node2D

# References to your nodes
var has_transitioned = false
@onready var player = $Player
@onready var progress_indicator = $UI/ProgressBar/ProgressIndicator
@onready var transition_area = $TransitionArea

# Your actual level boundaries
var level_start_x = -250.0
var level_end_x = 1200

# Progress bar boundaries on screen (in pixels)
var progress_bar_start = -200
var progress_bar_end = 1200.0

func _ready():
	# Initialize the level with starting position ONLY if no checkpoint exists
	# Wait a frame first to let CheckpointManager load its data
	await get_tree().process_frame
	
	# FIXED: Place player ON THE GROUND, not in the air
	var ground_spawn_position = Vector2(-101, -20)  # Much lower Y value to be on ground
	
	# Try to find the first checkpoint and use its position, but adjust Y coordinate to be ON GROUND
	var checkpoint_nodes = get_tree().get_nodes_in_group("checkpoints")
	if checkpoint_nodes.size() > 0:
		var checkpoint_pos = checkpoint_nodes[0].global_position
		# FIXED: Add to Y position to place player BELOW/ON GROUND relative to checkpoint
		# Since checkpoint is at Y -41, place player at around Y -20 to be on solid ground
		ground_spawn_position = Vector2(checkpoint_pos.x, checkpoint_pos.y + 25)  # CHANGED: + instead of -
		print("Using adjusted checkpoint position as default spawn: ", ground_spawn_position)
	
	if not CheckpointManager.current_checkpoint_set:
		CheckpointManager.initialize_level(ground_spawn_position)
	else:
		# If checkpoint exists, just set the default spawn but don't override checkpoint
		CheckpointManager.set_default_spawn(ground_spawn_position)
	
	# IMPORTANT: Move player to correct spawn position after scene loads
	call_deferred("position_player_at_spawn")
	
	# Debug: Print checkpoint status
	CheckpointManager.print_status()
	
	print("=== Checking existing nodes ===")
	print("Player found: ", player != null)
	print("Progress indicator found: ", progress_indicator != null)
	
	# Debug: Find all checkpoints
	print("=== Checkpoint Debug ===")
	var checkpoints = get_tree().get_nodes_in_group("checkpoints")
	print("Found ", checkpoints.size(), " checkpoints")
	for i in range(checkpoints.size()):
		var cp = checkpoints[i]
		print("Checkpoint ", i, ": ", cp.name, " at ", cp.global_position)
		if cp.has_method("get_checkpoint_id"):
			print("  ID: ", cp.get_checkpoint_id())
		print("  Monitoring: ", cp.monitoring)
		print("  Has CollisionShape2D: ", cp.get_child_count() > 0)
	
	if transition_area:
		transition_area.body_entered.connect(_on_transition_area_entered)
		print("Transition area connected!")
		print("Area2D monitoring: ", transition_area.monitoring)
		print("Area2D monitorable: ", transition_area.monitorable)
	else:
		print("No transition area found")
	
	if progress_indicator:
		print("=== Sprite Visibility Debug ===")
		print("Position: ", progress_indicator.position)
		print("Global Position: ", progress_indicator.global_position)
		print("Scale: ", progress_indicator.scale)
		print("Visible: ", progress_indicator.visible)
		print("Modulate: ", progress_indicator.modulate)
		print("Has animation: ", progress_indicator.sprite_frames != null)
		if progress_indicator.sprite_frames:
			print("Animation names: ", progress_indicator.sprite_frames.get_animation_names())
		
		# Force it to be visible and big for testing
		progress_indicator.visible = true
		progress_indicator.scale = Vector2(1.0, 1.0)
		progress_indicator.modulate = Color.WHITE
		progress_indicator.position = Vector2(200, 100)
		progress_indicator.play()
		
		print("After forcing visibility - Position: ", progress_indicator.position)
	else:
		print("Could not find ProgressIndicator at path: UI/ProgressBar/ProgressIndicator")
		print("Let's find where it actually is...")
		find_progress_indicator(self, "")

# NEW FUNCTION: Actually position the player at the correct spawn point
func position_player_at_spawn():
	if player:
		var spawn_pos = CheckpointManager.get_respawn_position()
		player.global_position = spawn_pos
		player.velocity = Vector2.ZERO
		print("Positioned player at spawn: ", spawn_pos)
		print("Player actual position after setting: ", player.global_position)
		
		# ADDED: Force the player to be on the ground by doing a quick collision check
		# This ensures the player doesn't spawn in mid-air
		await get_tree().process_frame
		if not player.is_on_floor():
			print("WARNING: Player not on floor at spawn position!")
			print("Player Y position: ", player.global_position.y)
			print("Consider adjusting spawn Y coordinate to be on solid ground")
			print("Try a higher Y value (like -15 or -10) to place player on ground")

func find_progress_indicator(node: Node, path: String):
	for child in node.get_children():
		var new_path = path + "/" + child.name if path != "" else child.name
		if child.name == "ProgressIndicator":
			print("*** FOUND ProgressIndicator at: ", new_path, " ***")
		find_progress_indicator(child, new_path)

func _process(delta):
	if progress_indicator:
		update_progress_bar()
	
	# Debug the overlap check
	if transition_area and player:
		var distance = player.global_position.distance_to(transition_area.global_position)
		if distance < 50.0 and not has_transitioned:
			has_transitioned = true
			print("Player close to transition area - transitioning!")
			transition_to_next_map()
		
		# Debug every few frames - but only if player is not falling off map
		if Engine.get_process_frames() % 60 == 0 and player.global_position.y < 1000:
			print("Player pos: ", player.global_position)
			print("Transition area pos: ", transition_area.global_position)
		
		# ADDED: Death trigger for falling off map
		if player.global_position.y > 1000:  # Adjust this value based on your level
			print("Player fell off the map!")
			player.take_damage()

func update_progress_bar():
	var player_x = player.global_position.x
	player_x = clamp(player_x, level_start_x, level_end_x)
	
	var progress = (player_x - level_start_x) / (level_end_x - level_start_x)
	var screen_position = progress_bar_start + (progress_bar_end - progress_bar_start) * progress
	
	progress_indicator.position.x = screen_position

func _on_transition_area_entered(body):
	print("=== COLLISION DETECTED ===")
	print("Body name: ", body.name)
	print("Body type: ", body.get_class())
	print("Player name: ", player.name)
	print("Player type: ", player.get_class())
	print("Are they equal? ", body == player)
	
	if body == player or body.name == player.name:
		print("MATCH! Transitioning...")
		transition_to_next_map()
	else:
		print("No match, ignoring")

func transition_to_next_map():
	get_tree().change_scene_to_file("res://Scenes/Game2.tscn")
