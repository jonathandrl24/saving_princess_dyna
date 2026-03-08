extends Node
# AudioManager.gd — Autoload: music and SFX

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var _sfx_pool_size: int = 8

var _music_volume: float = 0.8
var _sfx_volume: float = 1.0

var _current_music: String = ""

# Preloaded SFX paths (add actual .ogg/.wav files to assets/audio/)
const SFX_PATHS = {
	"shoot": "res://assets/audio/sfx/shoot.wav",
	"spam_mode": "res://assets/audio/sfx/spam_mode.wav",
	"enemy_hit": "res://assets/audio/sfx/enemy_hit.wav",
	"player_hit": "res://assets/audio/sfx/player_hit.wav",
	"pickup": "res://assets/audio/sfx/pickup.wav",
	"boss_roar": "res://assets/audio/sfx/boss_roar.wav",
	"jump": "res://assets/audio/sfx/jump.wav",
	"melee": "res://assets/audio/sfx/melee.wav",
	"death": "res://assets/audio/sfx/death.wav"
}

const MUSIC_PATHS = {
	"menu": "res://assets/audio/music/menu_theme.ogg",
	"world1": "res://assets/audio/music/world1_theme.ogg",
	"world2": "res://assets/audio/music/world2_theme.ogg",
	"world3": "res://assets/audio/music/world3_theme.ogg",
	"boss": "res://assets/audio/music/boss_theme.ogg",
	"final_boss": "res://assets/audio/music/final_boss_theme.ogg"
}

func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	# Create SFX pool
	for i in _sfx_pool_size:
		var sfx = AudioStreamPlayer.new()
		sfx.bus = "SFX"
		add_child(sfx)
		sfx_players.append(sfx)

func play_music(key: String, loop: bool = true):
	if _current_music == key:
		return
	var path = MUSIC_PATHS.get(key, "")
	if path == "" or not ResourceLoader.exists(path):
		return
	_current_music = key
	var stream = load(path)
	if stream is AudioStreamOggVorbis:
		stream.loop = loop
	music_player.stream = stream
	music_player.volume_db = linear_to_db(_music_volume)
	music_player.play()

func stop_music():
	music_player.stop()
	_current_music = ""

func play_sfx(key: String):
	var path = SFX_PATHS.get(key, "")
	if path == "" or not ResourceLoader.exists(path):
		return
	# Find free player in pool
	for sfx in sfx_players:
		if not sfx.playing:
			sfx.stream = load(path)
			sfx.volume_db = linear_to_db(_sfx_volume)
			sfx.play()
			return

func set_music_volume(vol: float):
	_music_volume = clamp(vol, 0.0, 1.0)
	music_player.volume_db = linear_to_db(_music_volume)

func set_sfx_volume(vol: float):
	_sfx_volume = clamp(vol, 0.0, 1.0)
