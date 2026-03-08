extends Area2D
# Checkpoint.gd

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: GPUParticles2D = $Particles

var _activated: bool = false
var checkpoint_id: int = 0

func _ready():
	body_entered.connect(_on_body_entered)
	if sprite:
		sprite.play("inactive")

func _on_body_entered(body: Node):
	if _activated:
		return
	if body.is_in_group("player"):
		_activate()

func _activate():
	_activated = true
	if sprite:
		sprite.play("active")
	if particles:
		particles.emitting = true
	# Save checkpoint
	GameManager.checkpoints_reached.append(checkpoint_id)
	AudioManager.play_sfx("pickup")
	# Heal slightly
	GameManager.heal(15)
