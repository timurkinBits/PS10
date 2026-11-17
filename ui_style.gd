extends RefCounted
## Помощники для создания и оформления элементов интерфейса.

const Data = preload("res://data.gd")

static var _bold: FontVariation


static func bold_font() -> Font:
	if _bold == null:
		_bold = FontVariation.new()
		_bold.base_font = ThemeDB.fallback_font
		_bold.variation_embolden = 0.9
	return _bold


static func lbl(text: String, size: int = 14, color: Color = Data.C_TEXT, bold: bool = false, wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if bold:
		l.add_theme_font_override("font", bold_font())
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


static func style(bg: Color, border: Color, bw: int, radius: int, pad: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(pad)
	return sb


static func box() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := style(Color.WHITE, Color(0, 0, 0, 0), 0, 8, 12)
	sb.shadow_color = Color(0, 0, 0, 0.13)
	sb.shadow_size = 2
	p.add_theme_stylebox_override("panel", sb)
	return p


static func main_button(b: Button) -> void:
	b.add_theme_stylebox_override("normal", style(Data.C_BLUE, Data.C_BLUE, 1, 6, 10))
	b.add_theme_stylebox_override("hover", style(Color("#1d4ed8"), Data.C_BLUE, 1, 6, 10))
	b.add_theme_stylebox_override("pressed", style(Color("#1e40af"), Data.C_BLUE, 1, 6, 10))
	b.add_theme_stylebox_override("focus", style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 6, 10))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, Color.WHITE)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


static func bar(fill_color: Color) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(60, 22)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.min_value = 0
	b.max_value = 100
	b.value = 0
	b.add_theme_stylebox_override("background", style(Color("#e5e7eb"), Color(0, 0, 0, 0), 0, 4, 0))
	b.add_theme_stylebox_override("fill", style(fill_color, Color(0, 0, 0, 0), 0, 4, 0))
	return b
