extends Control
## Отрисовка трассы и робота. Высота фиксированная, по ширине трасса растягивается.

const Data = preload("res://scripts/data.gd")
const DEFAULT_SCENE_PATH := "res://sprites/animation_robot.tscn"
const H := 112.0
const ROBOT_SCALE := 0.25 # размер робота на трассе (меняй по вкусу)
const ROBOT_Y := 60.0     # высота центра робота на трассе

const TERRAIN_SPRITES := {
	"Песок": preload("res://sprites/sand.png"),
	"Камни": preload("res://sprites/stones.png"),
	"Асфальт": preload("res://sprites/asphalt.png"),
	Data.NARROW: preload("res://sprites/narrow.png"),
}

var level: Dictionary = {}
var _robot: Node2D = null
var _anim_sprite: AnimatedSprite2D = null
var _anim_player: AnimationPlayer = null


func _init() -> void:
	custom_minimum_size = Vector2(0, H)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	resized.connect(_on_resized)

	_load_robot_scene(DEFAULT_SCENE_PATH, false)
	_update_robot_pos()


func _find_anim_sprite(node: Node) -> AnimatedSprite2D:
	for child in node.get_children():
		if child is AnimatedSprite2D:
			return child as AnimatedSprite2D
		var found := _find_anim_sprite(child)
		if found != null:
			return found
	return null


func _find_anim_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child as AnimationPlayer
		var found := _find_anim_player(child)
		if found != null:
			return found
	return null


func _load_robot_scene(scene_path: String, auto_play: bool) -> void:
	if _robot != null:
		_robot.queue_free()
		_robot = null
	_anim_sprite = null
	_anim_player = null

	var path := scene_path if ResourceLoader.exists(scene_path) else DEFAULT_SCENE_PATH
	var packed := load(path) as PackedScene
	if packed == null:
		return

	var inst := packed.instantiate()
	_robot = inst as Node2D
	if _robot == null:
		if inst != null:
			inst.queue_free()
		return

	add_child(_robot)
	_robot.scale = Vector2(ROBOT_SCALE, ROBOT_SCALE)
	_robot.z_index = 10

	if _robot is AnimatedSprite2D:
		_anim_sprite = _robot as AnimatedSprite2D
	else:
		_anim_sprite = _find_anim_sprite(_robot)

	_anim_player = _find_anim_player(_robot)

	_update_robot_pos()
	if auto_play:
		_play_move()
	else:
		_stop_anim()


func _play_move() -> void:
	if _anim_sprite != null and _anim_sprite.sprite_frames != null:
		var anim_name := "move"
		if not _anim_sprite.sprite_frames.has_animation(anim_name):
			var names := _anim_sprite.sprite_frames.get_animation_names()
			if names.size() > 0:
				anim_name = String(names[0])
		if _anim_sprite.sprite_frames.has_animation(anim_name):
			_anim_sprite.play(anim_name)
	elif _anim_player != null:
		var anims := _anim_player.get_animation_list()
		if anims.size() > 0:
			_anim_player.play(String(anims[0]))


func _stop_anim() -> void:
	if _anim_sprite != null:
		_anim_sprite.stop()
	if _anim_player != null:
		_anim_player.pause()


# Вызывается при нажатии «Отправить на миссию»
func start_mission(robot_data: Dictionary) -> void:
	var scene_path := str(robot_data.get("scene", DEFAULT_SCENE_PATH))
	progress_x = 0.0
	_load_robot_scene(scene_path, true)


# Вызывается при завершении заезда
func finish_mission(success: bool) -> void:
	if not success and _anim_sprite != null and _anim_sprite.sprite_frames != null and _anim_sprite.sprite_frames.has_animation("smoke"):
		_anim_sprite.play("smoke")
		return
	_stop_anim()


func _on_resized() -> void:
	_update_robot_pos()
	queue_redraw()


var progress_x := 0.0:
	set(v):
		progress_x = v
		_update_robot_pos()
		queue_redraw()


func _get_scale_k() -> float:
	if level.is_empty():
		return 1.0
	var total: float = Data.total(level)
	if total <= 0.0:
		return 1.0
	return (size.x - 60.0) / total


func _update_robot_pos() -> void:
	if _robot == null:
		return
	var k := _get_scale_k()
	_robot.position = Vector2(30.0 + progress_x * k, ROBOT_Y)


func set_level(lv: Dictionary) -> void:
	level = lv
	_update_robot_pos()
	queue_redraw()


# Выкладываем квадратные спрайты в ряд по ширине rect без растягивания пропорций
func _draw_terrain_row(tex: Texture2D, rect: Rect2) -> void:
	if tex == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var ts := tex.get_size()
	if ts.x <= 0.0 or ts.y <= 0.0:
		return

	var tile_size: float = rect.size.y
	var x := rect.position.x
	var right_edge := rect.position.x + rect.size.x

	while x < right_edge - 0.01:
		var step_w: float = minf(tile_size, right_edge - x)
		var frac_x: float = step_w / tile_size
		var src_rect := Rect2(0.0, 0.0, ts.x * frac_x, ts.y)
		var dst_rect := Rect2(x, rect.position.y, step_w, rect.size.y)
		draw_texture_rect_region(tex, dst_rect, src_rect)
		x += tile_size


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
		var y: float = 32.0
		var h: float = 58.0
		var rect := Rect2(30.0 + s * k, y, L * k, h)

		var tex: Texture2D = TERRAIN_SPRITES.get(seg_name)
		_draw_terrain_row(tex, rect)

		var tw: float = font.get_string_size(seg_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		if narrow or tw + 4.0 > L * k:
			var cx: float = 30.0 + (s + L / 2.0) * k
			draw_string(font, Vector2(cx - tw / 2.0, 102.0), seg_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.BLACK)
		else:
			draw_string(font, Vector2(32.0 + s * k, 20.0), seg_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.BLACK)
		s += L

	_update_robot_pos()
