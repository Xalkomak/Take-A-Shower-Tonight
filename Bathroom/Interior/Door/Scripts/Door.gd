extends Node3D

const DOOR_OPEN = preload("uid://po56jxgod4uc")
const DOOR_CLOSE = preload("uid://b1cl4ucsye8fr")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var burglar: Burglar = $Burglar
@onready var door_aud: AudioStreamPlayer3D = $Door_Group/DoorAud

func _ready() -> void:
	animation_player.play("BackHandleSwing")
	animation_player.play("FrontHandleSwing")

func open_door(stage: Burglar.Stages) -> void:
	if stage == Burglar.Stages.STAGE_3:
		animation_player.play("DoorOpen")
		door_aud.stream = DOOR_OPEN
		door_aud.play()
	elif stage == Burglar.Stages.INACTIVE:
		door_aud.stream = DOOR_CLOSE
		door_aud.play()
		animation_player.play_backwards("DoorOpen")

func process_burglar(active: bool) -> void:
	burglar.process_mode = Node.PROCESS_MODE_DISABLED if not active else Node.PROCESS_MODE_INHERIT

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "DoorOpen":
		await get_tree().create_timer(1).timeout
		process_burglar(true)

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "DoorOpen":
		process_burglar(false)
