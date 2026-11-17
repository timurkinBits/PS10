extends RefCounted
## Расчёт характеристик робота по деталям выбранного уровня.

const Data = preload("res://data.gd")


static func build(level: Dictionary, wheel_i: int, armor_i: int, bat_i: int) -> Dictionary:
	var parts: Dictionary = level["parts"]
	var W: Dictionary = parts["wheels"][wheel_i]
	var A: Dictionary = parts["armor"][armor_i]
	var B: Dictionary = parts["bats"][bat_i]
	var m: float = 50.0 + float(W["m"]) + float(A["m"]) + float(B["m"])
	return {
		"W": W,
		"m": m,
		"hp": 40.0 + float(A["hp"]),
		"en": 100.0 + float(B["e"]),
		"v": float(W["s"]) * 1500.0 / m,
		"drain": m * Data.DRAIN,
		"wide": int(W["w"]) > 1,
	}
