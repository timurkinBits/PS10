extends Control
## Отрисовка трассы и робота. Высота фиксированная, по ширине трасса растягивается.

const Data = preload("res://data.gd")
const H := 112.0

var level: Dictionary = {}


func _init() -> void:
	custom_minimum_size = Vector2(0, H)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	resized.connect(queue_redraw)


var progress_x := 0.0:
	set(v):
		progress_x = v
		queue_redraw()


func set_level(lv: Dictionary) -> void:
	level = lv
	queue_redraw()


func _draw() -> void:
	var w: float = size.x
	draw_rect(Rect2(0, 0, w, H), Color.WHITE)
	if level.is_empty():
		return
	var font: Font = get_theme_default_font()
	var total: float = Data.total(level)
	var k: float = (w - 60.0) / total   # пикселей на единицу длины
	var s := 0.0
	for g in level["seg"]:
		var seg_name: String = g["k"]
		var L: float = float(g["L"])
		var narrow: bool = seg_name == Data.NARROW
		var y: float = 46.0 if narrow else 32.0
		var h: float = 30.0 if narrow else 58.0
		draw_rect(Rect2(30.0 + s * k, y, L * k, h), Color.html(str(Data.TERRAIN_COLOR[seg_name])))
		var tw: float = font.get_string_size(seg_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		if narrow or tw + 4.0 > L * k:
			# сегмент узкий — подпись под ним по центру, чтобы не наезжала на соседний
			var cx: float = 30.0 + (s + L / 2.0) * k
			draw_string(font, Vector2(cx - tw / 2.0, 102.0), seg_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.BLACK)
		else:
			draw_string(font, Vector2(32.0 + s * k, 20.0), seg_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.BLACK)
		s += L
	draw_rect(Rect2(30.0 + progress_x * k - 10.0, 48.0, 20.0, 26.0), Data.C_BLUE)
