class_name Windowsill
extends Node3D

signal state_changed(new_state: States) ## Emitted when the state is changed.

# NOTE: Set the inital wait time to 47 for release

enum States {
	INACTIVE,
	EMERGING,
	KNOCKING,
	STALLING,
	JUMPSCARE
}

@onready var windowsill_anim: AnimationPlayer = $AnimationPlayer
@onready var windowsill_anim_tree: AnimationTree = $WindowsillAnimTree
@onready var windowsill_timer: Timer = $WindowsillTimer

var current_state: States:
	set(value):
		if current_state != value:
			current_state = value
			state_changed.emit(value)
var max_knocks: int = 3
var knock_count: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var knock_weights: Array[int] = [3, 3, 3, 3, 3, 2, 2, 2, 1, 1]

func _ready() -> void:
	windowsill_anim_tree.active = true
	$JumpscareCam.current = false

func _process(delta: float) -> void:
	windowsill_anim_tree.set("parameters/conditions/player_takes_bait",
	max_knocks < 3 and not GlobalScript.game_window_closed)

func set_knock_count() -> void:
	max_knocks = knock_weights.pick_random()
	knock_count = 0

func begin_wait() -> void:
	match  current_state:
		States.INACTIVE:
			windowsill_timer.wait_time = rng.randf_range(14.0, 18.0)
		States.EMERGING:
			windowsill_timer.wait_time = rng.randf_range(10.0, 16.0)
		States.KNOCKING: #In case of Windowsill baiting the player
			windowsill_timer.wait_time = rng.randf_range(2.0, 4.5)
		States.STALLING:
			windowsill_timer.wait_time = rng.randf_range(23.0, 47.0)
	
	windowsill_timer.start()

func increment_knock_count() -> void:
	knock_count += 1
	print("Knocked ", knock_count, " times")

func check_bait() -> void:
	if max_knocks == 3:
		current_state = States.INACTIVE
		begin_wait()
	else:
		state_changed.emit(States.INACTIVE)
		begin_wait()

func _on_windowsill_timer_timeout() -> void:
	match  current_state:
		States.INACTIVE:
			current_state = States.EMERGING
		States.EMERGING:
			if GlobalScript.game_window_closed:
				current_state = States.KNOCKING
			else:
				current_state = States.STALLING
		States.KNOCKING:
			if max_knocks < 3:
				current_state = States.EMERGING
		States.STALLING:
			current_state = States.JUMPSCARE

func _on_windowsill_anim_tree_animation_started(anim_name: StringName) -> void:
	if anim_name == "Jumpscare":
		current_state = States.JUMPSCARE
	if anim_name == "Knock_End":
		state_changed.emit(States.INACTIVE)
