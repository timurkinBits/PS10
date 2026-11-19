extends Control
## Кейс 4: «Надёжность vs скорость».
## Главный скрипт: переключает экраны — главное меню, выбор уровней, уровень, финал.

const MainMenu = preload("res://main_menu.gd")
const LevelMenu = preload("res://level_menu.gd")
const LevelScreen = preload("res://level_screen.gd")
const EndScreen = preload("res://end_screen.gd")
const Data = preload("res://data.gd")
const Progress = preload("res://progress.gd")

var _current: Control = null


func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = 14
	_show_main_menu()


func _show_main_menu() -> void:
	var m := MainMenu.new()
	m.play_pressed.connect(_play)
	m.levels_pressed.connect(_show_menu)
	m.progress_reset.connect(_show_main_menu)  # перестроить меню (звёзды, «Продолжить»)
	_swap(m)


func _show_menu() -> void:
	var menu := LevelMenu.new()
	menu.level_chosen.connect(_start_level)
	menu.back_requested.connect(_show_main_menu)
	_swap(menu)


## «Играть / Продолжить»: первый ещё не пройденный уровень.
## Если пройдено всё — открываем выбор уровня.
func _play() -> void:
	for i in Data.levels().size():
		if Progress.get_stars(i) == 0:
			_start_level(i)
			return
	_show_menu()


func _start_level(index: int) -> void:
	var screen := LevelScreen.new()
	screen.setup(index)
	screen.back_requested.connect(_show_menu)
	screen.next_requested.connect(_on_next.bind(index))
	_swap(screen)


func _on_next(index: int) -> void:
	if index + 1 < Data.levels().size():
		_start_level(index + 1)
	else:
		_show_end()


func _show_end() -> void:
	var e := EndScreen.new()
	e.levels_requested.connect(_show_menu)
	e.main_menu_requested.connect(_show_main_menu)
	_swap(e)


func _swap(node: Control) -> void:
	if _current != null:
		_current.queue_free()
	_current = node
	add_child(node)
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
