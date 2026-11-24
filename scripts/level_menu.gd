extends Control
## Меню выбора уровней. Закрытые уровни недоступны, пока не пройден предыдущий.

signal level_chosen(index: int)
signal back_requested

const Data = preload("res://scripts/data.gd")
const Style = preload("res://scripts/ui_style.gd")
const Progress = preload("res://scripts/progress.gd")
const BOTTOM_IMAGE_PATH := "res://sprites/robot_menu.png" # замени на нужный путь к картинке

var _grid: GridContainer
var _total_lbl: Label


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Data.C_BG
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var root_v := VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 0)
	add_child(root_v)
	root_v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# шапка
	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", Style.style(Color("#1f2937"), Color(0, 0, 0, 0), 0, 0, 8))
	var hrow := HBoxContainer.new()
	header.add_child(hrow)
	hrow.add_theme_constant_override("separation", 12)
	var back := Button.new()
	back.text = "← Главное меню"
	Style.main_button(back)
	back.pressed.connect(func() -> void: back_requested.emit())
	hrow.add_child(back)
	var title := Style.lbl("Надёжность vs скорость  —  выбор уровня", 17, Color.WHITE, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hrow.add_child(title)
	_total_lbl = Style.lbl("", 16, Color("#fbbf24"), true)
	hrow.add_child(_total_lbl)
	root_v.add_child(header)

	# карточки уровней
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_v.add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	scroll.add_child(margin)

	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	margin.add_child(_grid)

	# подвал с картинкой и кнопкой сброса
	var footer_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
<<<<<<< HEAD:scripts/level_menu.gd
		footer_margin.add_theme_constant_override("margin_" + side, 10)
	var footer_row := HBoxContainer.new()
	footer_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_theme_constant_override("separation", 12)
	footer_margin.add_child(footer_row)

	var pic := TextureRect.new()
	if ResourceLoader.exists(BOTTOM_IMAGE_PATH):
		pic.texture = load(BOTTOM_IMAGE_PATH) as Texture2D
	pic.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.custom_minimum_size = Vector2(0, 240) # высоту картинки можно менять здесь
	footer_row.add_child(pic)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(spacer)

	var reset := Button.new()
	reset.text = "Сбросить прогресс"
	reset.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reset.pressed.connect(_on_reset_pressed)
	footer_row.add_child(reset)

	root_v.add_child(footer_margin)
=======
		footer.add_theme_constant_override("margin_" + side, 10)
	var dialog := ConfirmationDialog.new()
	dialog.title = "Сброс прогресса"
	dialog.dialog_text = "Удалить все звёзды и закрыть уровни, кроме первого?\nЭто действие нельзя отменить."
	dialog.ok_button_text = "Сбросить"
	dialog.cancel_button_text = "Отмена"
	dialog.confirmed.connect(_on_reset_pressed)
	add_child(dialog)

	var reset := Button.new()
	reset.text = "Сбросить прогресс"
	reset.flat = true
	reset.size_flags_horizontal = Control.SIZE_SHRINK_END
	reset.add_theme_font_size_override("font_size", 12)
	reset.add_theme_color_override("font_color", Data.C_GRAY)
	reset.add_theme_color_override("font_hover_color", Color("#f87171"))
	reset.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset.pressed.connect(func() -> void: dialog.popup_centered())
	footer.add_child(reset)
	root_v.add_child(footer)
>>>>>>> 07879e6eb36f6985c96113f747d1c3109ae96d68:level_menu.gd

	_fill()


func _fill() -> void:
	for c in _grid.get_children():
		c.queue_free()
	for i in Data.levels().size():
		_grid.add_child(_make_card(i))
	_total_lbl.text = "Звёзд: %d / %d" % [Progress.total_stars(), Data.levels().size() * 3]


func _make_card(i: int) -> Control:
	var lv: Dictionary = Data.levels()[i]
	var unlocked := Progress.is_unlocked(i)
	var stars := Progress.get_stars(i)
	var col: Color = Data.C_TEXT if unlocked else Data.C_GRAY

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_FILL
	card.custom_minimum_size = Vector2(0, 170)
	var bg: Color = Color.WHITE if unlocked else Color("#e5e7eb")
	var border: Color = Data.C_BLUE if unlocked else Color("#d1d5db")
	card.add_theme_stylebox_override("panel", Style.style(bg, border, 2, 10, 12))

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)

	v.add_child(Style.lbl("Уровень %d" % (i + 1), 12, Data.C_GRAY))
	v.add_child(Style.lbl(str(lv["name"]), 18, col, true))
	v.add_child(Style.lbl(str(lv["desc"]), 13, Data.C_GRAY, false, true))
	v.add_child(Style.lbl("Маршрут: " + Data.route_text(lv), 13, col, false, true))
	v.add_child(Style.lbl("★★★: финиш, время ≤ %d с, масса ≤ %d кг (лимит %d с)" % [int(lv["star_t"]), int(lv["star_m"]), int(lv["limit"])], 12, Data.C_GRAY, false, true))

	if unlocked:
		var star_col: Color = Data.C_STAR if stars > 0 else Data.C_GRAY
		v.add_child(Style.lbl(Data.stars_text(stars), 22, star_col, true))
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(_on_card_input.bind(i))
	else:
		v.add_child(Style.lbl("Закрыто: пройдите предыдущий уровень", 13, Data.C_GRAY, true))
	return card


func _on_card_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		level_chosen.emit(index)


func _on_reset_pressed() -> void:
	Progress.reset()
	_fill()
