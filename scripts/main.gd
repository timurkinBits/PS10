extends Control
## Кейс 4: «Надёжность vs скорость».
## Главный скрипт: переключает экраны — меню выбора уровней и сам уровень.

const LevelMenu = preload("res://scripts/level_menu.gd")
const LevelScreen = preload("res://scripts/level_screen.gd")
const Data = preload("res://scripts/data.gd")

var _current: Control = null


func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = 14
	_show_menu()


func _show_menu() -> void:
	var menu := LevelMenu.new()
	menu.level_chosen.connect(_start_level)
	_swap(menu)


func _start_level(index: int) -> void:
	var screen := LevelScreen.new()
	screen.setup(index)
	screen.back_requested.connect(_show_menu)
	screen.next_requested.connect(_start_level.bind(index + 1))
	_swap(screen)


func _swap(node: Control) -> void:
	if _current != null:
		_current.queue_free()
	_current = node
	add_child(node)
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
