class_name LightsOut
extends Decal

signal stage_changed(new_stage: Stages) ## Emitted when entering a new stage.

enum Stages {
	INACTIVE,
	SUBTLE,
	ANNOUNCEMENT,
	ASSAULT,
	JUMPSCARE
}

## NOTE: Set initial wait time to 69 for release.

@onready var lo_timer: Timer = $LOTimer
@onready var lo_anim_player: AnimationPlayer = %LOAnimPlayer

@export var props: Array[Displaceable]

var current_stage: Stages = Stages.INACTIVE:
	set(new_stage):
		if current_stage != new_stage:
			current_stage = new_stage
			stage_changed.emit(current_stage)
			is_active = (
				current_stage == Stages.SUBTLE or 
				current_stage == Stages.ANNOUNCEMENT or 
				current_stage == Stages.ASSAULT
			)
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spawn_points: Array[Node]
var is_active: bool
var lights_off_elapsed: float
var lights_off_threshold: float = 6
var prop_elapsed: float

func _ready() -> void:
	spawn_points = get_tree().get_nodes_in_group("SpawnPoints")

func _process(delta: float) -> void:
	if not is_active:
		lights_off_elapsed = 0
		return
	
	if not GlobalScript.game_light_on and is_active:
		lights_off_elapsed += delta
	
	displace_prop()
	
	if lights_off_elapsed >= lights_off_threshold:
		current_stage = Stages.INACTIVE
		global_position = Vector3(0, 0, 2)
		for prop in props:
			prop.global_transform = prop.initial_transform
		lo_timer.stop()
		lights_off_elapsed = 0
		lo_timer.wait_time = rng.randf_range(30, 46)
		lo_timer.start()

func _on_lo_timer_timeout() -> void:
	match current_stage:
		Stages.INACTIVE:
			lo_timer.wait_time = rng.randf_range(20, 31)
			if GlobalScript.game_light_on:
				lights_off_threshold = rng.randf_range(4, 8)
				current_stage = Stages.SUBTLE
		Stages.SUBTLE:
			lo_timer.wait_time = rng.randf_range(18, 29)
			current_stage = Stages.ANNOUNCEMENT
		Stages.ANNOUNCEMENT:
			lo_timer.wait_time = rng.randf_range(16, 27)
			current_stage = Stages.ASSAULT
			var selected_point: Marker3D = spawn_points.pick_random() as Marker3D
			global_transform = selected_point.global_transform
		Stages.ASSAULT:
			current_stage = Stages.JUMPSCARE
			lo_anim_player.play("Jumpscare")
	
	lo_timer.start()

func displace_prop() -> void:
	var prop: Displaceable = props.pick_random() as Displaceable
	match current_stage:
		Stages.SUBTLE:
			GlobalScript.lights_out_is_ready = false
			prop_elapsed += get_process_delta_time()
			if prop_elapsed > 8.7:
				prop_elapsed = 0.0
				prop.random_transform()
		Stages.ANNOUNCEMENT, Stages.ASSAULT:
			GlobalScript.lights_out_is_ready = true
			prop.random_transform()

func jumpscare() -> void:
	EventBus.player_killed.emit(GlobalScript.MONSTERS.LIGHTS_OUT)
