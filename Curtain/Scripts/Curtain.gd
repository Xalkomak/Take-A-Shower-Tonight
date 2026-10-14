class_name Curtain
extends AnimatableBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable_component: Interactable = $Interactable

var disable_control: bool
var is_open: bool = false

signal curtain_toggled(toggled: bool)

func toggle_curtain() -> void:
	animation_player.play("Open") if not is_open and not disable_control else animation_player.play_backwards("Open")
	disable_control = true
	interactable_component.allow_interact = not disable_control
	is_open = not is_open

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	disable_control = false
	interactable_component.allow_interact = not disable_control
	curtain_toggled.emit(is_open)
	EventBus.game_curtain_toggled.emit()
