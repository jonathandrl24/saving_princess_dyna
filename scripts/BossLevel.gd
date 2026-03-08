extends "res://scripts/BaseLevel.gd"
# BossLevel.gd — Boss arena logic

@export var boss_name: String = "Commander"

var _boss: Node = null

func _ready():
	super._ready()
	AudioManager.play_music("boss")
	# Find boss node
	for child in get_children():
		if child.is_in_group("boss") or child.get_script() != null and "Boss" in child.get_script().resource_path:
			_boss = child
			break
	# Also try by class
	_boss = _find_boss(self)
	if _boss:
		_boss.boss_damaged.connect(_on_boss_damaged)
		_boss.boss_died.connect(_on_boss_died)
		if hud and hud.has_method("show_boss_health"):
			hud.show_boss_health(boss_name, _boss.health, _boss.max_health)
		AudioManager.play_sfx("boss_roar")

func _find_boss(node: Node) -> Node:
	for child in node.get_children():
		if child.has_method("_boss_ready"):
			return child
	return null

func _on_boss_damaged(current: int, max_val: int):
	if hud and hud.has_method("update_boss_health"):
		hud.update_boss_health(current, max_val)

func _on_boss_died():
	if hud and hud.has_method("hide_boss_health"):
		hud.hide_boss_health()
