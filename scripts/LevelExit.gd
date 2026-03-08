extends Area2D
# LevelExit.gd — Trigger to advance to next level

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		GameManager.complete_level()
