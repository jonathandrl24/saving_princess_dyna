extends Area2D
# EnemyBullet.gd — Enemy projectile

@export var speed: float = 250.0
@export var damage: int = 10
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.LEFT

func _ready():
	add_to_group("enemy_bullets")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float):
	position += direction * speed * delta

func _on_body_entered(body: Node):
	if body.is_in_group("terrain"):
		queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("player_hurtbox"):
		queue_free()
