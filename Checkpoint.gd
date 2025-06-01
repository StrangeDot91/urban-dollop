# Checkpoint.gd - Attach to Area2D nodes placed throughout your level
extends Area2D

@export var is_active = false
@export var checkpoint_id: String = ""  # Set this in the editor for each checkpoint
@onready var sprite = $Sprite2D  # Add a visual indicator

func _ready():
	# Connect the signal properly
	body_entered.connect(_on_body_entered)
	
	# Generate ID if not set
	if checkpoint_id == "":
		checkpoint_id = "checkpoint_" + str(global_position.x) + "_" + str(global_position.y)
	
	add_to_group("checkpoints")
	
	# Simple check: if this checkpoint position matches the current checkpoint, activate it
	call_deferred("check_if_should_be_active")

func check_if_should_be_active():
	var current_checkpoint_pos = CheckpointManager.get_respawn_position()
	var current_default_pos = CheckpointManager.default_spawn_position
	
	# If the current checkpoint position matches this checkpoint's position (and it's not the default spawn)
	if current_checkpoint_pos.distance_to(global_position) < 10.0 and current_checkpoint_pos != current_default_pos:
		is_active = true
		print("Restoring checkpoint: ", checkpoint_id, " at ", global_position)
	else:
		is_active = false
	
	update_visual()

func _on_body_entered(body):
	print("Checkpoint touched by: ", body.name, " (type: ", body.get_class(), ")")
	
	# FIXED: Remove the "Player" type check that was causing the error
	# Just check by name and class name instead
	if (body.name == "Player" or body.get_class() == "CharacterBody2D") and not is_active:
		print("Activating checkpoint: ", checkpoint_id)
		activate_checkpoint()

func activate_checkpoint():
	is_active = true
	CheckpointManager.set_checkpoint(global_position, checkpoint_id)
	update_visual()
	
	# Deactivate other checkpoints
	var checkpoints = get_tree().get_nodes_in_group("checkpoints")
	for checkpoint in checkpoints:
		if checkpoint != self and checkpoint.has_method("deactivate"):
			checkpoint.deactivate()

func deactivate():
	is_active = false
	update_visual()

func update_visual():
	# Change sprite/color based on active state
	if sprite:
		if is_active:
			sprite.modulate = Color.GREEN
			print("Checkpoint ", checkpoint_id, " is now GREEN (active)")
		else:
			sprite.modulate = Color.WHITE
