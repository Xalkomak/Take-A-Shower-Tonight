class_name PeepingTom
extends Node3D

signal stage_changed(new_stage: STAGES)

const POSITIONS: Array[Vector2] = [
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(0, -1)
]

enum STAGES {
	INACTIVE,
	PEEPING,
	JUMPSCARE
}

@onready var jumpscare_cam: Camera3D = $JumpscareCam
@onready var pt_timer: Timer = $PT_Timer # NOTE: Set initial wait time to 21 for release
@onready var pt_anim_tree: AnimationTree = $PT_AnimTree

@export var staredown_threshold: float = 5.0 ## Baseline time required to scare Peeping Tom away.
@export var max_jumps: int = 5 ## Baseline number of times Peeping Tom jumps around to avoid eye contact (Nightmare mode only).

var is_observed: bool
var staredown_elapsed: float
var jump_count: int
var current_stage: STAGES = STAGES.INACTIVE:
	set(new_stage):
		if current_stage != new_stage:
			current_stage = new_stage
			print(current_stage)
			stage_changed.emit(new_stage)
			jumpscare_cam.current = current_stage == STAGES.JUMPSCARE

func _physics_process(delta: float) -> void:
	if current_stage == STAGES.INACTIVE:
		staredown_elapsed = 0
		return
	
	if is_observed:
		staredown_elapsed += delta
	
	if staredown_elapsed > staredown_threshold:
		is_observed = false
		staredown_elapsed = 0.0
		pt_timer.stop()
		pt_anim_tree.set("parameters/Peeping/Exit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		current_stage = STAGES.INACTIVE
		begin_wait()

func begin_wait() -> void:
	match current_stage:
		STAGES.INACTIVE:
			pt_timer.wait_time = randf_range(12.0, 17.0) # 22, 57
		STAGES.PEEPING:
			pt_timer.wait_time = randf_range(8.0, 9.0) # 18, 29
	print(pt_timer.wait_time)
	pt_timer.start()

func force_stage_change(stage: STAGES) -> void:
	current_stage = stage
	if current_stage != STAGES.JUMPSCARE:
		begin_wait()

func _on_pt_timer_timeout() -> void:
	match current_stage:
		STAGES.INACTIVE:
			current_stage = STAGES.PEEPING
			var random_position: Vector2 = POSITIONS.pick_random()
			pt_anim_tree.set("parameters/Peeping/Positions/blend_position", random_position)
			begin_wait()
		STAGES.PEEPING:
			current_stage = STAGES.JUMPSCARE

func _on_stare_zone_area_entered(area: Area3D) -> void:
	if current_stage == STAGES.PEEPING:
		is_observed = true

func _on_stare_zone_area_exited(area: Area3D) -> void:
	if current_stage == STAGES.PEEPING:
		is_observed = false
