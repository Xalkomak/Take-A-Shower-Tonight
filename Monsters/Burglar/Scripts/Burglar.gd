class_name Burglar
extends Node3D

# NOTE: Set the initial wait time to 94 for release.

enum Stages {
	INACTIVE,
	STAGE_1,
	STAGE_2,
	STAGE_3,
	JUMPSCARE
}

@onready var burglar_timer: Timer = $BurglarTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jumpscare_cam: Camera3D = %JumpscareCam

var current_stage: Stages = Stages.INACTIVE:
	set(new_stage):
		if current_stage != new_stage:
			current_stage = new_stage
			EventBus.burglar_stage_changed.emit(current_stage)
			set_process(current_stage == Stages.STAGE_3)

func _ready() -> void:
	jumpscare_cam.current = false
	set_process(current_stage == Stages.STAGE_3)
	EventBus.game_shower_toggled.connect(detect_player_action)
	EventBus.game_light_toggled.connect(detect_player_action)
	EventBus.game_window_toggled.connect(detect_player_action)
	EventBus.game_curtain_toggled.connect(detect_player_action)

func _process(delta: float) -> void:
	if GlobalScript.game_shower_on or GlobalScript.game_curtain_open:
		jumpscare_player()

func _on_burglar_timer_timeout() -> void:
	match current_stage:
		Stages.INACTIVE:
			current_stage = Stages.STAGE_1
			burglar_timer.wait_time = randf_range(8.0, 9.0)
			print("Burglar is ready.")
		Stages.STAGE_1:
			current_stage = Stages.STAGE_2
			burglar_timer.wait_time = randf_range(9.0, 10.0)
			print("Burglar is coming.")
		Stages.STAGE_2:
			current_stage = Stages.STAGE_3
			burglar_timer.wait_time = randf_range(5.0, 6.0)
			print("Burglar is inside.")
		Stages.STAGE_3:
			current_stage = Stages.INACTIVE
			burglar_timer.wait_time = randf_range(4.0, 5.0) # 47, 65
			print("Burglar has left.")
	burglar_timer.start()

func detect_player_action():
	if current_stage == Stages.STAGE_3 and not process_mode == PROCESS_MODE_DISABLED:
		jumpscare_player()

func jumpscare_player() -> void:
	current_stage = Stages.JUMPSCARE
	animation_player.play("Burglar_Jumpscare")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Burglar_Jumpscare":
		EventBus.player_killed.emit(GlobalScript.KILLED_BY.BURGLAR)
