extends Area2D
# PowerUp.gd — Health, Ammo, Spam Box, Shield

enum Type { HEALTH, AMMO, SPAM_BOX, SHIELD }

@export var type: Type = Type.HEALTH
@export var value: int = 25  # Amount for health/ammo

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var bob_tween: Tween

var _bob_offset: float = 0.0

func _ready():
	add_to_group("powerups")
	body_entered.connect(_on_body_entered)
	_setup_visuals()
	_start_bob()

func _setup_visuals():
	match type:
		Type.HEALTH:
			modulate = Color.GREEN
			if label: label.text = "HP"
		Type.AMMO:
			modulate = Color.CYAN
			if label: label.text = "AMMO"
		Type.SPAM_BOX:
			modulate = Color.YELLOW
			if label: label.text = "SPAM!"
		Type.SHIELD:
			modulate = Color.WHITE
			if label: label.text = "SHIELD"

func _start_bob():
	bob_tween = create_tween().set_loops()
	bob_tween.tween_property(self, "position:y", position.y - 8, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(self, "position:y", position.y + 8, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		_apply_effect()
		AudioManager.play_sfx("pickup")
		queue_free()

func _apply_effect():
	match type:
		Type.HEALTH:
			GameManager.heal(value)
		Type.AMMO:
			GameManager.add_ammo(value)
		Type.SPAM_BOX:
			GameManager.activate_spam_mode()
		Type.SHIELD:
			GameManager.activate_shield()
