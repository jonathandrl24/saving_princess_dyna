extends Control
# OptionsMenu.gd

@onready var music_slider: HSlider = $VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $VBox/SFXRow/SFXSlider
@onready var back_button: Button = $VBox/BackButton

func _ready():
	music_slider.value = 0.8
	sfx_slider.value = 1.0
	music_slider.value_changed.connect(func(v): AudioManager.set_music_volume(v))
	sfx_slider.value_changed.connect(func(v): AudioManager.set_sfx_volume(v))
	back_button.pressed.connect(func(): SceneManager.goto_main_menu())
