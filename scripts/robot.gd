extends RefCounted
## Расчёт характеристик робота по деталям выбранного уровня.

const Data = preload("res://scripts/data.gd")

const WHEEL_SCENES := {
	"Лёгкие колёса": "res://sprites/animation_robot.tscn",
	"Вездеходные": "res://sprites/animation_robot_offroad.tscn",
	"Гусеницы": "res://sprites/animation_robot_tracks.tscn",
	"Шипованные": "res://sprites/animation_robot_spiked.tscn",
	"Гоночные": "res://sprites/animation_robot_racing.tscn",
	"Баллоны": "res://sprites/animation_robot_balloon.tscn",
}


static func _scene_for_wheel(W: Dictionary, wheel_i: int) -> String:
	var wheel_name := str(W.get("n", ""))
	if WHEEL_SCENES.has(wheel_name):
		return str(WHEEL_SCENES[wheel_name])

	var by_idx := [
		"res://sprites/animation_robot.tscn",
		"res://sprites/animation_robot_offroad.tscn",
		"res://sprites/animation_robot_tracks.tscn",
		"res://sprites/animation_robot_spiked.tscn",
		"res://sprites/animation_robot_racing.tscn",
		"res://sprites/animation_robot_balloon.tscn",
	]
	if wheel_i >= 0 and wheel_i < by_idx.size():
		return by_idx[wheel_i]
	return "res://sprites/animation_robot.tscn"


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
		"scene": _scene_for_wheel(W, wheel_i),
	}
