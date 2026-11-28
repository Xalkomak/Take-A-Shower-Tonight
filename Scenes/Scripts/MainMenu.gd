extends Node3D

@export var prologue_scene: PackedScene

func _on_quit_pressed() -> void:
	get_tree().quit()

func _ready() -> void:
	%VersionNumber.text = "v%s" % ProjectSettings.get_setting("application/config/version", "0.0.0")

func _on_play_pressed() -> void:
	%CurtainAnim.play("Open")

func _on_curtain_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Open":
		get_tree().change_scene_to_packed(prologue_scene)
