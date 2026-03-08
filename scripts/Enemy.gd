extends CharacterBody2D
# Enemy.gd — Base class for all enemies

@export var max_health: int = 30
@export var move_speed: float = 80.0
@export var damage_on_contact: int = 10
@export var score_value: int = 100
@export var knockback_force: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox

var health: int
var is_dead: bool = false
var player_ref: Node = null
var _knockback: Vector2 = Vector2.ZERO

const GRAVITY: float = 980.0

signal died(enemy: Node)
signal damaged(amount: int)

func _ready():
	health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_entered)
	_find_player()
	_on_ready_extra()

func _on_ready_extra():
	pass  # Override in subclasses

func _find_player():
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float):
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if _knockback != Vector2.ZERO:
		velocity = _knockback
		_knockback = _knockback.lerp(Vector2.ZERO, 0.3)
		if _knockback.length() < 5:
			_knockback = Vector2.ZERO
	_ai_process(delta)
	move_and_slide()

func _ai_process(_delta: float):
	pass  # Override in subclasses

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO):
	if is_dead:
		return
	health -= amount
	damaged.emit(amount)
	AudioManager.play_sfx("enemy_hit")
	_show_damage_flash()
	if knockback_dir != Vector2.ZERO:
		_knockback = knockback_dir * knockback_force
	if health_bar:
		health_bar.value = health
	if health <= 0:
		die()

func _show_damage_flash():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

func die():
	if is_dead:
		return
	is_dead = true
	GameManager.add_score(score_value)
	died.emit(self)
	_on_die()
	sprite.play("die")
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _on_die():
	pass  # Override for drops, VFX etc

func _on_hurtbox_entered(area: Area2D):
	if area.is_in_group("player_bullets"):
		var knockback = (global_position - area.global_position).normalized()
		take_damage(area.damage, knockback)
		area.get_parent().queue_free()
	elif area.is_in_group("player_melee"):
		var knockback = (global_position - area.global_position).normalized()
		take_damage(area.damage, knockback)

func _face_player():
	if player_ref:
		sprite.flip_h = player_ref.global_position.x < global_position.x
