extends CanvasLayer

var _busy: bool = false
var _duration: float = 0.45

@onready var _rect: ColorRect = $ColorRect

func _ready() -> void:
	layer = 100
	_rect.visible = true
	_rect.color = Color(0, 0, 0, 1)
	_rect.modulate.a = 0.0
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Ensure fullscreen anchors
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.offset_left = 0
	_rect.offset_top = 0
	_rect.offset_right = 0
	_rect.offset_bottom = 0

func change_scene(target_path: String, duration: float = 0.45) -> void:
	if _busy:
		return
	if target_path == "":
		push_warning("SceneTransition: empty target_path")
		return
	_busy = true
	_duration = duration
	# Block input during fade
	get_tree().paused = false

	var tween_in := create_tween()
	tween_in.tween_property(_rect, "modulate:a", 1.0, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_in.finished

	get_tree().change_scene_to_file(target_path)

	# Wait for new scene to be ready (one frame + small delay for _ready)
	await get_tree().process_frame
	await get_tree().process_frame

	var tween_out := create_tween()
	tween_out.tween_property(_rect, "modulate:a", 0.0, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_out.finished

	_busy = false

func is_busy() -> bool:
	return _busy
