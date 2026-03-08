extends CharacterBody2D
# Boss.gd — Base class with phases

@export var phase_health_thresholds: Array[float] = [0.66, 0.33]
@export var max_health: int = 300
@export var score_value: int = 1000

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $BossHealthBar
@onready var hurtbox: Area2D = $Hurtbox

var health: int
var current_phase: int = 1
var is_dead: bool = false
var player_ref: Node = null
var _phase_changing: bool = false

signal phase_changed(new_phase: int)
signal boss_died
signal boss_damaged(current_hp: int, max_hp: int)

const GRAVITY: float = 980.0

func _ready():
	health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	player_ref = get_tree().get_first_node_in_group("player")
	if hurtbox:
		hurtbox.area_entered.connect(_on_hurtbox_entered)
	_boss_ready()

func _boss_ready():
	pass  # Override

func _physics_process(delta: float):
	if is_dead or _phase_changing:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	_boss_process(delta)
	move_and_slide()

func _boss_process(_delta: float):
	pass  # Override

func take_damage(amount: int):
	if is_dead or _phase_changing:
		return
	health -= amount
	health = max(0, health)
	if health_bar:
		health_bar.value = health
	boss_damaged.emit(health, max_health)
	AudioManager.play_sfx("enemy_hit")
	_damage_flash()
	_check_phase_transition()
	if health <= 0:
		die()

func _check_phase_transition():
	var hp_ratio = float(health) / float(max_health)
	var next_phase = 1
	for i in phase_health_thresholds.size():
		if hp_ratio <= phase_health_thresholds[i]:
			next_phase = i + 2
	if next_phase > current_phase:
		_transition_to_phase(next_phase)

func _transition_to_phase(new_phase: int):
	_phase_changing = true
	current_phase = new_phase
	phase_changed.emit(new_phase)
	AudioManager.play_sfx("boss_roar")
	# Flash effect
	var tween = create_tween()
	for i in 4:
		tween.tween_property(sprite, "modulate", Color.YELLOW, 0.15)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	await tween.finished
	_phase_changing = false
	_on_phase_enter(new_phase)

func _on_phase_enter(_phase: int):
	pass  # Override

func _damage_flash():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.08).timeout
	sprite.modulate = Color.WHITE

func die():
	if is_dead:
		return
	is_dead = true
	boss_died.emit()
	GameManager.add_score(score_value)
	_on_boss_die()
	sprite.play("die")
	set_collision_layer_value(1, false)
	await get_tree().create_timer(2.5).timeout
	GameManager.complete_level()

func _on_boss_die():
	pass  # Override for VFX, dialogue, etc.

func _on_hurtbox_entered(area: Area2D):
	if area.is_in_group("player_bullets"):
		take_damage(area.damage)
		area.get_parent().queue_free()
