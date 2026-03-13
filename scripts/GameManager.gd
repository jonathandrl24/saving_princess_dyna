extends Node
# GameManager.gd
# Keeps track of global game data.
# Right now it only needs to exist so SceneManager can call reset_game().
# We will add health, ammo, lives etc. when we build the gameplay.

var player_lives: int = 3
var player_score: int = 0

func reset_game():
	player_lives = 3
	player_score = 0
