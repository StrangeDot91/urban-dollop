extends Node2D

const SPEED = 60
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
# In your enemy script or collision detection
func _on_enemy_hit_player(player):
	if player.has_method("take_damage"):
		player.take_damage()
# Called when the node enters the scene tree for the first time.
func _delta_process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
