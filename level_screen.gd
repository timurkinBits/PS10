extends Control
## Экран одного уровня: сборка робота и гонка.
## Раньше это был main.gd. Перед добавлением в дерево вызовите setup(index).

signal back_requested
signal next_requested

const Data = preload("res://data.gd")
const Style = preload("res://ui_style.gd")
const Robot = preload("res://robot.gd")
const Race = preload("res://race.gd")
const PartGrid = preload("res://part_grid.gd")
const TrackView = preload("res://track_view.gd")
const Progress = preload("res://progress.gd")

var level_index := 0
var level: Dictionary = {}

var sel := {"w": 0, "a": 0, "b": 0}
var race: Race = null

var stats_grid: GridContainer
var _stat_vals: Array = []
var _stat_units: Array = []
var track: Control
var hp_bar: ProgressBar
var en_bar: ProgressBar
var time_lbl: Label
var msg_lbl: Label
var best_lbl: Label
var next_btn: Button


func setup(index: int) -> void:
	level_index = index
	level = Data.levels()[index]


func _ready() -> void:
	_build_ui()
	_render_stats()
	_update_best()


# ======================================================================
#  ИНТЕРФЕЙС
# ======================================================================
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Data.C_BG
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var root_v := VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 0)
	add_child(root_v)
	root_v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	root_v.add_child(_build_header())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_v.add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	scroll.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	content.add_child(_build_goal())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	content.add_child(row)
	row.add_child(_build_parts_box())
	row.add_child(_build_stats_box())

	# блок гонки закреплён внизу окна и не прокручивается
	var bottom := MarginContainer.new()
	bottom.add_theme_constant_override("margin_left", 16)
	bottom.add_theme_constant_override("margin_right", 16)
	bottom.add_theme_constant_override("margin_top", 0)
	bottom.add_theme_constant_override("margin_bottom", 10)
	bottom.add_child(_build_track_box())
	root_v.add_child(bottom)


func _build_header() -> Control:
	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", Style.style(Color("#1f2937"), Color(0, 0, 0, 0), 0, 0, 8))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	header.add_child(row)

	var back := Button.new()
	back.text = "← Меню"
	Style.main_button(back)
	back.pressed.connect(func() -> void: back_requested.emit())
	row.add_child(back)

	var title := Style.lbl("Уровень %d: «%s»" % [level_index + 1, str(level["name"])], 17, Color.WHITE, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title)

	best_lbl = Style.lbl("", 16, Color("#fbbf24"), true)
	best_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(best_lbl)
	return header


func _update_best() -> void:
	best_lbl.text = "Рекорд: " + Data.stars_text(Progress.get_stars(level_index))


func _build_goal() -> Control:
	var goal := PanelContainer.new()
	var sb := Style.style(Color("#eef2ff"), Data.C_BLUE, 0, 8, 8)
	sb.border_width_left = 4
	goal.add_theme_stylebox_override("panel", sb)
	var txt := RichTextLabel.new()
	txt.bbcode_enabled = true
	txt.fit_content = true
	txt.scroll_active = false
	txt.add_theme_font_size_override("normal_font_size", 13)
	txt.add_theme_font_size_override("bold_font_size", 13)
	txt.add_theme_color_override("default_color", Data.C_TEXT)
	txt.add_theme_font_override("bold_font", Style.bold_font())
	txt.text = "%s\nМаршрут: %s. Лимит времени: [b]%d с[/b]. Звёзды: ★ за финиш, ★ за время ≤ [b]%d с[/b], ★ за массу ≤ [b]%d кг[/b]. Рабочих сборок несколько — найдите ту, что даёт все три звезды." % [
		str(level["desc"]), Data.route_text(level), int(level["limit"]), int(level["star_t"]), int(level["star_m"])]
	goal.add_child(txt)
	return goal


func _build_parts_box() -> Control:
	var box := Style.box()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	box.add_child(v)
	# набор деталей свой для каждого уровня
	var parts: Dictionary = level["parts"]
	v.add_child(Style.lbl("Колёса", 15, Data.C_TEXT, true))
	v.add_child(_make_grid(parts["wheels"], "w"))
	v.add_child(Style.lbl("Защита корпуса", 15, Data.C_TEXT, true))
	v.add_child(_make_grid(parts["armor"], "a"))
	v.add_child(Style.lbl("Запасной аккумулятор", 15, Data.C_TEXT, true))
	v.add_child(_make_grid(parts["bats"], "b"))
	return box


func _make_grid(items: Array, key: String) -> Control:
	var grid := PartGrid.new()
	grid.setup(items)
	grid.picked.connect(_on_part_picked.bind(key))
	return grid


func _build_stats_box() -> Control:
	var box := Style.box()
	box.custom_minimum_size.x = 280
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	box.add_child(v)
	v.add_child(Style.lbl("Параметры робота", 15, Data.C_TEXT, true))
	stats_grid = GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 12)
	stats_grid.add_theme_constant_override("v_separation", 2)
	v.add_child(stats_grid)
	var btn := Button.new()
	btn.text = "Отправить на миссию"
	Style.main_button(btn)
	btn.pressed.connect(_on_run_pressed)
	v.add_child(btn)
	return box


func _build_track_box() -> Control:
	var box := Style.box()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	box.add_child(v)

	track = TrackView.new()
	track.set_level(level)
	v.add_child(track)

	var info := HBoxContainer.new()
	info.add_theme_constant_override("separation", 12)
	v.add_child(info)

	var hp_box := HBoxContainer.new()
	hp_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_box.add_child(Style.lbl("HP"))
	hp_bar = Style.bar(Color("#dc2626"))
	hp_box.add_child(hp_bar)
	info.add_child(hp_box)

	var en_box := HBoxContainer.new()
	en_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	en_box.add_child(Style.lbl("Энергия"))
	en_bar = Style.bar(Color("#16a34a"))
	en_box.add_child(en_bar)
	info.add_child(en_box)

	var time_box := HBoxContainer.new()
	time_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	time_box.add_child(Style.lbl("Время: "))
	time_lbl = Style.lbl("0.0", 14, Data.C_TEXT, true)
	time_box.add_child(time_lbl)
	time_box.add_child(Style.lbl(" / %d с" % int(level["limit"])))
	info.add_child(time_box)

	var msg_row := HBoxContainer.new()
	msg_row.add_theme_constant_override("separation", 12)
	v.add_child(msg_row)

	msg_lbl = Style.lbl("", 14, Data.C_TEXT, true, true)
	msg_lbl.custom_minimum_size.y = 38
	msg_row.add_child(msg_lbl)

	# появляется после успешного прохождения, если есть следующий уровень
	next_btn = Button.new()
	next_btn.text = "Следующий уровень →" if level_index + 1 < Data.levels().size() else "Завершить игру →"
	Style.main_button(next_btn)
	next_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	next_btn.visible = false
	next_btn.pressed.connect(func() -> void: next_requested.emit())
	msg_row.add_child(next_btn)
	return box


# ======================================================================
#  ВЫБОР ДЕТАЛЕЙ / ПАРАМЕТРЫ
# ======================================================================
func _on_part_picked(index: int, key: String) -> void:
	sel[key] = index
	_render_stats()


func _current_robot() -> Dictionary:
	return Robot.build(level, sel["w"], sel["a"], sel["b"])


func _render_stats() -> void:
	if _stat_vals.is_empty():
		for title in ["Масса", "Скорость", "Прочность", "Расход энергии", "Ширина"]:
			stats_grid.add_child(Style.lbl(title))
			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 0)
			var val := Style.lbl("", 14, Data.C_TEXT, true)
			var unit := Style.lbl("")
			h.add_child(val)
			h.add_child(unit)
			stats_grid.add_child(h)
			_stat_vals.append(val)
			_stat_units.append(unit)
	var r := _current_robot()
	_set_stat(0, "%d" % int(r["m"]), " кг")
	_set_stat(1, "%.1f" % float(r["v"]), " м/с")
	_set_stat(2, "%d" % int(r["hp"]), " HP")
	_set_stat(3, "%.1f" % float(r["drain"]), " ед/с из %d" % int(r["en"]))
	_set_stat(4, "широкий" if r["wide"] else "узкий", "")


func _set_stat(i: int, value: String, unit: String) -> void:
	_stat_vals[i].text = value
	_stat_units[i].text = unit


# ======================================================================
#  ГОНКА
# ======================================================================
func _on_run_pressed() -> void:
	race = Race.new(_current_robot(), level)
	hp_bar.max_value = race.hp
	hp_bar.value = race.hp
	en_bar.max_value = race.en
	en_bar.value = race.en
	time_lbl.text = "0.0"
	track.progress_x = 0.0
	next_btn.visible = false
	_set_msg("Робот в пути...", Data.C_TEXT)


func _set_msg(text: String, color: Color) -> void:
	msg_lbl.text = text
	msg_lbl.add_theme_color_override("font_color", color)


func _process(delta: float) -> void:
	if race == null or race.finished:
		return
	race.step(minf(delta, 0.05) * Data.TIME_SCALE)
	hp_bar.value = maxf(0.0, race.hp)
	en_bar.value = maxf(0.0, race.en)
	time_lbl.text = "%.1f" % race.t
	track.progress_x = race.x
	if race.finished:
		_set_msg(race.message, Data.C_OK if race.success else Data.C_BAD)
		if race.success:
			Progress.set_stars(level_index, race.stars)
			_update_best()
			next_btn.visible = true
