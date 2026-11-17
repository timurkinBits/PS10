extends RefCounted
## Прогресс игрока: лучшие результаты (звёзды) по уровням, хранится в user://progress.cfg.
## Уровень открыт, если предыдущий пройден хотя бы на одну звезду.

const Data = preload("res://data.gd")
const PATH := "user://progress.cfg"


static func _load() -> ConfigFile:
	var cf := ConfigFile.new()
	cf.load(PATH)  # если файла ещё нет — просто пустой конфиг
	return cf


static func get_stars(index: int) -> int:
	return int(_load().get_value("stars", "level_%d" % index, 0))


## Сохраняет результат, только если он лучше прежнего.
static func set_stars(index: int, stars: int) -> void:
	if stars <= get_stars(index):
		return
	var cf := _load()
	cf.set_value("stars", "level_%d" % index, stars)
	cf.save(PATH)


static func is_unlocked(index: int) -> bool:
	return index == 0 or get_stars(index - 1) > 0


static func total_stars() -> int:
	var n := 0
	for i in Data.levels().size():
		n += get_stars(i)
	return n


static func reset() -> void:
	ConfigFile.new().save(PATH)
