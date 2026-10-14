class_name Burglar
extends CharacterBody3D

signal new_stage_entered(new_stage: Stages) ## Emitted when a new stage is entered.

# NOTE: Set the initial wait time to 94 for release.

const INACTIVE_POS := Vector3(-6, 0, -6)
const STAGE1_POS := Vector3(-6, 0, -6)
const STAGE2_POS := Vector3(-0.6, 0, -6)
const STAGE3_POS := Vector3(0, 0, -4)

enum Stages {
	INACTIVE,
	STAGE_1,
	STAGE_2,
	STAGE_3,
	JUMPSCARE
}

@onready var burglar_timer: Timer = $BurglarTimer
@onready var burglar_anim: AnimationPlayer = $BurglarAnim

var current_stage: Stages = Stages.INACTIVE:
	set(new_stage):
		if current_stage != new_stage:
			current_stage = new_stage
			new_stage_entered.emit(current_stage)
			set_process(current_stage == Stages.STAGE_3)
			move_to_pos()

func _ready() -> void:
	set_process(current_stage == Stages.STAGE_3)
	EventBus.game_shower_toggled.connect(detect_player_action)
	EventBus.game_light_toggled.connect(detect_player_action)
	EventBus.game_window_toggled.connect(detect_player_action)
	EventBus.game_curtain_toggled.connect(detect_player_action)

func _process(delta: float) -> void:
	if GlobalScript.game_shower_on or GlobalScript.game_curtain_open:
		print("Burglar can detect you!")
	else:
		print("Burglar doesn't detect you!")

func move_to_pos():
	var tween: Tween = get_tree().create_tween()
	var new_pos: Vector3 = INACTIVE_POS
	match current_stage:
		Stages.STAGE_1:
			new_pos = STAGE1_POS
		Stages.STAGE_2:
			new_pos = STAGE2_POS
		Stages.STAGE_3:
			new_pos = STAGE3_POS
	tween.tween_property(self, "position", new_pos, 1).set_ease(Tween.EASE_OUT)
	tween.bind_node(self)

func _on_burglar_timer_timeout() -> void:
	match current_stage:
		Stages.INACTIVE:
			current_stage = Stages.STAGE_1
			burglar_timer.wait_time = 8.6
			print("Burglar is ready.")
		Stages.STAGE_1:
			current_stage = Stages.STAGE_2
			burglar_timer.wait_time = 9.3
			print("Burglar is coming.")
		Stages.STAGE_2:
			current_stage = Stages.STAGE_3
			burglar_timer.wait_time = 6.1
			print("Burglar is inside.")
		Stages.STAGE_3:
			current_stage = Stages.INACTIVE
			burglar_timer.wait_time = randf_range(47, 65)
			print("Burglar has left.")
	
	burglar_timer.start()

func detect_player_action():
	if current_stage == Stages.STAGE_3:
		print("Burglar can detect player action.")
