extends Control
# MainMenu.gd
# Shows the title screen.
# Play button → goes to Level 1.
# Quit button → closes the game.

func _ready():
	# Connect buttons to functions
	$VBox/PlayButton.pressed.connect(_on_play)
	$VBox/QuitButton.pressed.connect(_on_quit)

func _on_play():
	SceneManager.start_game()

func _on_quit():
	get_tree().quit()
