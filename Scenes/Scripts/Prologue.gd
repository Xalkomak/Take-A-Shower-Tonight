extends ColorRect

const GAME: PackedScene = preload("uid://bcwey6fe7pb8i")

@onready var prologue_text_1: Label = $VBoxContainer/PrologueText1
@onready var prologue_text_2: Label = $VBoxContainer/PrologueText2
@onready var prologue_animator: AnimationPlayer = $VBoxContainer/PrologueAnimator

func _ready() -> void:
	prologue_text_1.visible_characters = 0
	prologue_text_2.visible_characters = 0
	await get_tree().create_timer(1.0).timeout
	prologue_animator.play("Prologue")

func _on_prologue_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Prologue":
		SceneSwitcher.change_scene(GAME)
