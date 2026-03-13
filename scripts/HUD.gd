extends CanvasLayer

@onready var barra = $VBoxContainer/ProgressBar

func _ready():
	var fill = StyleBoxFlat.new()
	fill.bg_color = Color(0.8, 0.1, 0.1)  # red
	barra.add_theme_stylebox_override("fill", fill)
	
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.2, 0.2, 0.2)
	barra.add_theme_stylebox_override("background", bg)

func actualizar_vida(vida: int):
	barra.value = vida
