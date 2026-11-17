extends RefCounted
## Симуляция одной гонки на заданном уровне. Не знает ничего про интерфейс.

const Data = preload("res://data.gd")

var robot: Dictionary
var level: Dictionary
var total := 0.0
var rocks_len := 0.0

var x := 0.0
var t := 0.0
var hp := 0.0
var en := 0.0

var finished := false
var success := false
var stars := 0
var message := ""


func _init(r: Dictionary, lv: Dictionary) -> void:
	robot = r
	level = lv
	total = Data.total(lv)
	rocks_len = Data.length_of(lv, Data.ROCKS)
	hp = float(r["hp"])
	en = float(r["en"])


func seg_at(pos: float) -> Dictionary:
	var segs: Array = level["seg"]
	var s := 0.0
	for g in segs:
		if pos < s + float(g["L"]):
			return g
		s += float(g["L"])
	return segs[segs.size() - 1]


func _finish(text: String, ok: bool) -> void:
	finished = true
	success = ok
	message = text


## dt — шаг симуляции в секундах (уже с учётом ускорения).
func step(dt: float) -> void:
	if finished:
		return
	var W: Dictionary = robot["W"]
	var seg_name: String = seg_at(x)["k"]

	if seg_name == Data.NARROW and robot["wide"]:
		_finish("Застрял: робот слишком широкий для узкого прохода. Попробуйте колёса уже.", false)
		return

	var sp: float = float(robot["v"])
	if seg_name == Data.SAND:
		sp *= float(W["sand"])
	if seg_name == Data.ROCKS:
		sp *= 0.7

	var dx: float = minf(sp * dt, total - x)
	x += dx
	t += dx / sp
	en -= dx / sp * float(robot["drain"])
	if seg_name == Data.ROCKS:
		hp -= dx * Data.DMG * float(W["rock"])

	if hp <= 0.0:
		var need: int = ceili(rocks_len * Data.DMG * float(W["rock"]) - float(robot["hp"]))
		_finish("Сломался на камнях: не хватило %d HP. Нужна защита или колёса покрепче." % need, false)
		return
	if en <= 0.0:
		_finish("Кончилась энергия на %d%% маршрута. Робот слишком тяжёлый или нужен запасной аккумулятор." % roundi(x / total * 100.0), false)
		return
	if x >= total:
		var limit: float = float(level["limit"])
		var star_t: float = float(level["star_t"])
		var star_m: float = float(level["star_m"])
		if t > limit:
			_finish("Доехал, но не успел: %.1f с при лимите %d с. Лишний вес замедлил робота." % [t, int(limit)], false)
			return
		stars = 1
		if t <= star_t:
			stars += 1
		if float(robot["m"]) <= star_m:
			stars += 1
		_finish("Миссия выполнена! %s Время %.1f с, осталось %d HP и %d энергии. (★ за финиш, ★ за время ≤ %d с, ★ за массу ≤ %d кг)" % [Data.stars_text(stars), t, roundi(hp), roundi(en), int(star_t), int(star_m)], true)
