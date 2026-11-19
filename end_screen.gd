extends Control
## Экран завершения игры: показывается после прохождения последнего уровня.

signal levels_requested
signal main_menu_requested

const Data = preload("res://data.gd")
const Style = preload("res://ui_style.gd")
const Progress = preload("res://progress.gd")


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Data.C_BG
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box := Style.box()
	box.custom_minimum_size.x = 520
	center.add_child(box)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	box.add_child(v)

	var count: int = Data.levels().size()
	var total := Progress.total_stars()
	var perfect := total == count * 3

	var title := Style.lbl("Игра пройдена!", 32, Data.C_OK, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)

	var text := "Идеально: все звёзды собраны!" if perfect else "Все уровни пройдены. Вернитесь и соберите оставшиеся звёзды."
	var sub := Style.lbl(text, 15, Data.C_GRAY, false, true)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sub)

	var sum := Style.lbl("Звёзд: %d / %d" % [total, count * 3], 22, Data.C_STAR, true)
	sum.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sum)

	v.add_child(HSeparator.new())

	# результаты по уровням
	for i in count:
		var row := HBoxContainer.new()
		var name_lbl := Style.lbl("%d. %s" % [i + 1, str(Data.levels()[i]["name"])], 15)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)
		var s := Progress.get_stars(i)
		row.add_child(Style.lbl(Data.stars_text(s), 18, Data.C_STAR if s > 0 else Data.C_GRAY, true))
		v.add_child(row)

	v.add_child(HSeparator.new())

	var b1 := Button.new()
	b1.text = "К выбору уровня"
	b1.custom_minimum_size.y = 40
	Style.main_button(b1)
	b1.pressed.connect(func() -> void: levels_requested.emit())
	v.add_child(b1)

	var b2 := Button.new()
	b2.text = "Главное меню"
	b2.custom_minimum_size.y = 40
	Style.main_button(b2)
	b2.pressed.connect(func() -> void: main_menu_requested.emit())
	v.add_child(b2)
