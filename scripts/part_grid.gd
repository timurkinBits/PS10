extends GridContainer
## Сетка компактных карточек деталей (колёса / защита / аккумулятор) с выбором кликом.

signal picked(index: int)

const Data = preload("res://scripts/data.gd")
const Style = preload("res://scripts/ui_style.gd")

var _cards: Array = []
var _sb_norm: StyleBoxFlat
var _sb_sel: StyleBoxFlat


func setup(items: Array) -> void:
	columns = 3
	add_theme_constant_override("h_separation", 6)
	add_theme_constant_override("v_separation", 6)
	_sb_norm = Style.style(Color.WHITE, Color("#d1d5db"), 2, 8, 6)
	_sb_sel = Style.style(Color("#eff6ff"), Data.C_BLUE, 2, 8, 6)

	for i in items.size():
		var p: Dictionary = items[i]
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(150, 62)
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 0)
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(Style.lbl(str(p["n"]), 14, Data.C_TEXT, true))
		v.add_child(Style.lbl("масса +%d · %s" % [int(p["m"]), str(p["d"])], 12, Data.C_GRAY, false, true))
		card.add_child(v)
		card.gui_input.connect(_on_card_input.bind(i))
		add_child(card)
		_cards.append(card)
	select(0)


func select(index: int) -> void:
	for i in _cards.size():
		var card: PanelContainer = _cards[i]
		card.add_theme_stylebox_override("panel", _sb_sel if i == index else _sb_norm)


func _on_card_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select(index)
		picked.emit(index)
