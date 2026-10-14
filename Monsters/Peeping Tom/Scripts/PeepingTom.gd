class_name PeepingTom
extends CharacterBody3D

signal phase_changed(new_phase: Phases) ## Emitted when a new phase is entered.

# NOTE: Set the inital Wait Time to 21 and Autostart to "True" for release

const bathroom_area: Vector2 = Vector2(1.9, 3.4)
const bathroom_area_center: Vector3 = Vector3(0, 0, -3.3)
const inactive_pos: Vector3 = Vector3(0, 0, -8)

enum Phases {
	INACTIVE,
	PEEPING,
	RESISTING,
	JUMPSCARE
}

@onready var p_tom_timer: Timer = $PTomTimer
@onready var jumpscare_cam: Camera3D = $JumpscareCam

@export var jump_speed: float = 0.2
@export var observe_time_threshold: float = 0.9

var can_be_observed: bool
var current_phase: Phases = Phases.INACTIVE:
	set(new_phase):
		if current_phase != new_phase:
			current_phase = new_phase
			phase_changed.emit(new_phase)
			jumpscare_cam.current = current_phase == Phases.JUMPSCARE
		can_be_observed = current_phase == Phases.PEEPING or current_phase == Phases.RESISTING
var rng: VectorRNG = VectorRNG.new()
var is_observed: bool
var observe_time_elapsed: float
var max_jumps: int = 5
var jump_count: int

func _physics_process(delta: float) -> void:
	handle_being_observed(delta)

func jump_to_position() -> void:
	var new_pos: Vector3
	if jump_count < max_jumps:
		new_pos = rng.rand_on_unit_plane(bathroom_area_center, bathroom_area)
	else:
		p_tom_timer.stop()
		new_pos = inactive_pos
		is_observed = false
		current_phase = Phases.INACTIVE
		begin_wait()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_pos, jump_speed)
	tween.bind_node(self)

func begin_wait() -> void:
	match current_phase:
		Phases.INACTIVE:
			p_tom_timer.wait_time = rng.randf_range(22.0, 57.0)
		Phases.PEEPING:
			p_tom_timer.wait_time = rng.randf_range(18.0, 29.0)
		Phases.RESISTING:
			p_tom_timer.wait_time = 10
	
	p_tom_timer.start()

func _on_ptom_timer_timeout() -> void:
	match current_phase:
		Phases.INACTIVE:
			jump_count = 0
			current_phase = Phases.PEEPING
			max_jumps = rng.randi_range(3, 6)
			jump_to_position()
			begin_wait()
		Phases.PEEPING:
			current_phase = Phases.JUMPSCARE
		Phases.RESISTING:
			if jump_count < max_jumps:
				current_phase = Phases.JUMPSCARE

func handle_being_observed(delta: float) -> void:
	#can_be_observed = current_phase == Phases.PEEPING or current_phase == Phases.RESISTING
	
	if not can_be_observed:
		observe_time_elapsed = 0
		return
	
	if is_observed:
		begin_resisting()
		observe_time_elapsed += delta
	else:
		observe_time_elapsed = 0
	
	if observe_time_elapsed >= observe_time_threshold:
		observe_time_threshold = rng.randf_range(0.6, 1.16)
		observe_time_elapsed = 0
		jump_to_position()
		jump_count += 1

func begin_resisting() -> void:
	if current_phase != Phases.RESISTING and is_observed:
		p_tom_timer.stop()
		current_phase = Phases.RESISTING
		begin_wait()

func _on_face_area_entered(area: Area3D) -> void:
	if can_be_observed:
		is_observed = true

func _on_face_area_exited(area: Area3D) -> void:
	if can_be_observed:
		is_observed = false
