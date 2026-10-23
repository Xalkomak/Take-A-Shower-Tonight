class_name WindowProp
extends AnimatableBody3D

@onready var window_anim: AnimationPlayer = $WindowAnim
@onready var interactable: Interactable = $Interactable

signal window_shut(is_shut: bool)

func toggle_window() -> void:
	interactable.allow_interact = false
	window_anim.play("Window_Shut") if interactable.interaction_state else window_anim.play_backwards("Window_Shut")

func _on_window_anim_animation_finished(anim_name: StringName) -> void:
	interactable.allow_interact = true
	window_shut.emit(interactable.interaction_state)
	EventBus.game_window_toggled.emit()
