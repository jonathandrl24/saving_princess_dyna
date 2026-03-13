extends Control
# Play button → goes to Level 1.
# Quit button → closes the game.

func _ready():
	# Connect buttons to functions
	$VBoxContainer/PlayAgainButton.pressed.connect(_on_play)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_play():
	SceneManager.start_game()

func _on_quit():
	get_tree().quit()
