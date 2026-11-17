extends RefCounted
## Общие данные: список уровней, константы и цвета.
## Каждый уровень лежит в levels/level_XX.gd и отдаёт свои данные через get_data().

const LEVEL_SCRIPTS := [
	"res://levels/level_01.gd",
	"res://levels/level_02.gd",
	"res://levels/level_03.gd",
	"res://levels/level_04.gd",
]

# Ленивая загрузка: уровни читаются через load(), а не через preload и не через
# константы других скриптов, чтобы не было циклических зависимостей при разборе.
static var _levels: Array = []


static func levels() -> Array:
	if _levels.is_empty():
		for path in LEVEL_SCRIPTS:
			_levels.append(load(path).get_data())
	return _levels


const DRAIN := 0.045      # расход энергии на кг массы
const DMG := 0.5          # урон на камнях
const TIME_SCALE := 3.0   # ускорение симуляции (как в оригинале)

const ASPHALT := "Асфальт"
const SAND := "Песок"
const ROCKS := "Камни"
const NARROW := "Узкий проход"
const TERRAIN_COLOR := {
	ASPHALT: "#6b7280",
	SAND: "#fbbf24",
	ROCKS: "#78716c",
	NARROW: "#1f2937",
}

const C_BG := Color("#f3f4f6")
const C_TEXT := Color("#111111")
const C_GRAY := Color("#6b7280")
const C_BLUE := Color("#2563eb")
const C_OK := Color("#15803d")
const C_BAD := Color("#b91c1c")
const C_STAR := Color("#d97706")


## Полная длина трассы уровня.
static func total(lv: Dictionary) -> float:
	var s := 0.0
	for g in lv["seg"]:
		s += float(g["L"])
	return s


## Суммарная длина сегментов заданного типа.
static func length_of(lv: Dictionary, kind: String) -> float:
	var s := 0.0
	for g in lv["seg"]:
		if g["k"] == kind:
			s += float(g["L"])
	return s


static func route_text(lv: Dictionary) -> String:
	var parts := PackedStringArray()
	for g in lv["seg"]:
		parts.append(str(g["k"]))
	return " → ".join(parts)


static func stars_text(n: int) -> String:
	return "★".repeat(n) + "☆".repeat(3 - n)
