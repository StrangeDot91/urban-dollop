# LivesUI.gd - Attach to a Label in your UI
extends Label

func _ready():
	LivesManager.lives_changed.connect(_on_lives_changed)
	_on_lives_changed(LivesManager.get_lives())

func _on_lives_changed(new_lives):
	text = " " + str(new_lives)
	
	# Optional: Add visual effects for life loss
	if new_lives < LivesManager.max_lives:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.2)
		tween.tween_property(self, "modulate", Color.WHITE, 0.2)
