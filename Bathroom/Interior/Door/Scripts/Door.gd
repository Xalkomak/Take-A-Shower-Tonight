extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var burglar: Burglar = $Burglar

func _ready() -> void:
	animation_player.play("BackHandleSwing")
	animation_player.play("FrontHandleSwing")
	EventBus.burglar_stage_changed.connect(open_door)

func open_door(stage: Burglar.Stages) -> void:
	if stage == Burglar.Stages.STAGE_3:
		animation_player.play("DoorOpen")
	elif stage == Burglar.Stages.INACTIVE:
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
