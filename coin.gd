extends Area2D

func _ready():
	# Connect the signal properly
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# FIXED: Remove the "Player" type check that was causing the error
	# Just check by name and class name instead
	if body.name == "Player" or body.get_class() == "CharacterBody2D":
		print("+1 coin!")
		queue_free()
