class_name SceneSwitcherScript
extends Control

@onready var fade_box: ColorRect = $FadeBox
var active_tween: Tween

func _ready() -> void:
	fade_box.color = Color(Color.BLACK, 0)

func change_scene(requested_scene: PackedScene) -> void:
	if active_tween and active_tween.is_running():
		active_tween.kill()
	
	active_tween = get_tree().create_tween()
	active_tween.tween_property(fade_box, "color", Color(Color.BLACK, 1), 1.0)
	active_tween.finished.connect(func():
		get_tree().change_scene_to_packed(requested_scene)
		)
	await get_tree().create_timer(randf_range(1.0, 1.2)).timeout
	active_tween.kill()
	active_tween = get_tree().create_tween()
	active_tween.tween_property(fade_box, "color", Color(Color.BLACK, 0), 1.0)
