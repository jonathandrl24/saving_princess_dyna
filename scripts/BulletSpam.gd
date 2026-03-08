extends Area2D
# BulletSpam.gd — Spam Mode bullet (faster, chaos)

@export var speed: float = 750.0
@export var damage: int = 10
@export var lifetime: float = 1.5

var direction: Vector2 = Vector2.RIGHT

func _ready():
	add_to_group("player_bullets")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	# Small VFX: scale pop
	scale = Vector2(0.6, 0.6)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float):
	position += direction * speed * delta

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemy_hurtbox"):
		queue_free()

func _on_body_entered(body: Node):
	if body.is_in_group("terrain"):
		queue_free()
