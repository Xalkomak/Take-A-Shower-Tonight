extends Node3D

@export var prologue_scene: PackedScene
var scene_switcher: Control

func _on_quit_pressed() -> void:
	get_tree().quit()

func _ready() -> void:
	scene_switcher = get_tree().get_first_node_in_group("Scene Switcher")
	%VersionNumber.text = "v%s" % ProjectSettings.get_setting("application/config/version", "0.0.0")

func _on_play_pressed() -> void:
	%CurtainAnim.play("Open")

func _on_curtain_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Open":
		var scene_switcher_script := scene_switcher.get_script() as SceneSwitcherScript
		scene_switcher.change_scene(prologue_scene)
