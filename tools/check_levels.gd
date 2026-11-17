extends SceneTree
## Проверка баланса уровней. Запуск из папки проекта:
##   godot --headless -s tools/check_levels.gd
## Для каждого уровня перебирает все сборки при разных шагах симуляции и проверяет:
##   1) проходят хотя бы 2 сборки;
##   2) 3 звезды даёт ровно одна;
##   3) результат не зависит от частоты кадров (нет сборок «на грани»).

const Data = preload("res://data.gd")
const Robot = preload("res://robot.gd")
const Race = preload("res://race.gd")

# шаги симуляции в секундах (в игре это кадр * TIME_SCALE, т.е. до 0.15)
const DTS := [0.01, 0.03, 0.05, 0.08, 0.11, 0.15]


func _init() -> void:
	var failed := false
	for li in Data.levels().size():
		var lv: Dictionary = Data.levels()[li]
		var parts: Dictionary = lv["parts"]
		var total := 0
		var passers := 0
		var threes: Array = []
		var unstable: Array = []
		for wi in parts["wheels"].size():
			for ai in parts["armor"].size():
				for bi in parts["bats"].size():
					total += 1
					var robot := Robot.build(lv, wi, ai, bi)
					var results := {}
					for dt in DTS:
						results[_run(robot, lv, dt)] = true
					var title := "%s + %s + %s" % [
						str(parts["wheels"][wi]["n"]), str(parts["armor"][ai]["n"]), str(parts["bats"][bi]["n"])]
					if results.size() > 1:
						unstable.append(title)
					var best: int = results.keys().max()
					if best > 0:
						passers += 1
					if best == 3:
						threes.append(title)
		var problems: Array = []
		if passers < 2:
			problems.append("проходит меньше двух сборок")
		if threes.size() != 1:
			problems.append("3★ у %d сборок (нужна ровно одна)" % threes.size())
		if not unstable.is_empty():
			problems.append("результат зависит от шага симуляции: " + ", ".join(unstable))
		var ok := problems.is_empty()
		failed = failed or not ok
		print("Уровень %d «%s»: проходят %d из %d; 3★: %s  [%s]" % [
			li + 1, str(lv["name"]), passers, total, ", ".join(threes), "OK" if ok else "ОШИБКА"])
		for p in problems:
			print("    - ", p)
	quit(1 if failed else 0)


func _run(robot: Dictionary, lv: Dictionary, dt: float) -> int:
	var race := Race.new(robot, lv)
	while not race.finished:
		race.step(dt)
	return race.stars if race.success else 0
