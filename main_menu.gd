extends Control
## Главное меню: Играть / Выбор уровня / Выход.

signal play_pressed
signal levels_pressed
signal progress_reset

const Data = preload("res://data.gd")
const Style = preload("res://ui_style.gd")
const Progress = preload("res://progress.gd")


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#1f2937")
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.custom_minimum_size.x = 340
	center.add_child(v)

	var title := Style.lbl("Надёжность vs скорость", 36, Color.WHITE, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)

	var sub := Style.lbl("Соберите робота и доведите его до финиша", 15, Color("#9ca3af"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sub)

	var stars := Style.lbl("Звёзд: %d / %d" % [Progress.total_stars(), Data.levels().size() * 3], 18, Color("#fbbf24"), true)
	stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(stars)

	v.add_child(Control.new())

	var started := Progress.total_stars() > 0
	v.add_child(_btn("Продолжить" if started else "Играть", func() -> void: play_pressed.emit()))
	v.add_child(_btn("Выбор уровня", func() -> void: levels_pressed.emit()))
	v.add_child(_btn("Выход", func() -> void: get_tree().quit()))

	_add_reset_button()


## Маленькая кнопка сброса в правом нижнем углу + окно подтверждения.
func _add_reset_button() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Сброс прогресса"
	dialog.dialog_text = "Удалить все звёзды и закрыть уровни, кроме первого?\nЭто действие нельзя отменить."
	dialog.ok_button_text = "Сбросить"
	dialog.cancel_button_text = "Отмена"
	dialog.confirmed.connect(_on_reset_confirmed)
	add_child(dialog)

	var reset := Button.new()
	reset.text = "Сбросить прогресс"
	reset.flat = true
	reset.add_theme_font_size_override("font_size", 12)
	reset.add_theme_color_override("font_color", Color("#9ca3af"))
	reset.add_theme_color_override("font_hover_color", Color("#f87171"))
	reset.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset.pressed.connect(func() -> void: dialog.popup_centered())
	add_child(reset)
	reset.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 12)


func _on_reset_confirmed() -> void:
	Progress.reset()
	progress_reset.emit()


func _btn(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = 44
	b.add_theme_font_size_override("font_size", 18)
	Style.main_button(b)
	b.pressed.connect(action)
	return b
