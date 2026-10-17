class_name Game
extends Node3D

const END_SCREEN = preload("res://Scenes/EndScreen.tscn")

static var steam_density: float

@onready var shower_progress: ProgressBar = %ShowerProgress
@onready var steam: FogVolume = %Steam
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var abyss: Abyss = $AbyssMockup
@onready var player: Player = $Player

@export var steam_buildup_rate: float = 1.0

var curtain: Curtain
var shower: Shower
var window: WindowProp
var light: LightMechanic
var shower_multiplier: float = 1.0
var soap_bonus: float = 0.0
var shower_on: bool
var curtain_open: bool
var window_closed: bool
var lights_out_monster: LightsOut
var flicker_sdfgi: bool

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
#region Get References
	curtain = get_tree().get_first_node_in_group("curtain") as Curtain
	shower = get_tree().get_first_node_in_group("shower") as Shower
	window = get_tree().get_first_node_in_group("window") as WindowProp
	light = get_tree().get_first_node_in_group("Light") as LightMechanic
	lights_out_monster = get_tree().get_first_node_in_group("Monster_LO") as LightsOut
#endregion
	
#region Signal Connection
	window.window_shut.connect(on_window_shut)
	curtain.curtain_toggled.connect(on_curtain_toggled)
	shower.shower_toggled.connect(on_shower_toggled)
	window.window_anim.animation_finished.connect(on_window_animation_finished)
	light.light_toggled.connect(on_light_toggled)
	lights_out_monster.stage_changed.connect(on_lo_stage_changed)
	EventBus.game_soap_used.connect(on_soap_used)
	EventBus.player_killed.connect(on_player_killed)
#endregion
	
	shower_progress.value = 0

func _process(delta: float) -> void:
	shower_multiplier = (1.0 if shower_on else 0.0) + (soap_bonus if shower_on else 0.0)
	if shower_on:
		shower_multiplier += 0.75 if not curtain_open else 0.0
	
	shower_progress.value += delta * shower_multiplier
	
	soap_bonus -= delta * 0.5 # Adjust this magic number to determine how long the soap penalty lasts
	soap_bonus = clamp(soap_bonus, 0.0, 2.5)
	player.allow_interact = soap_bonus < 0.5
	
	if shower_on and window_closed:
		steam_density += delta * steam_buildup_rate
	elif not window_closed:
		steam_density -= delta * steam_buildup_rate
	steam_density = clamp(steam_density, -1.0, 3.1)
	steam.material.set("density", steam_density)
	
	if flicker_sdfgi:
		sdfgi_flickering()

	if shower_progress.value >= shower_progress.max_value:
		get_tree().change_scene_to_packed(END_SCREEN)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		get_tree().quit()
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func on_window_shut(is_shut: bool) -> void:
	window_closed = is_shut
	GlobalScript.game_window_closed = window_closed

func on_curtain_toggled(toggled: bool) -> void:
	curtain_open = toggled
	GlobalScript.game_curtain_open = curtain_open

func on_shower_toggled(toggled: bool) -> void:
	shower_on = toggled
	GlobalScript.game_shower_on = shower_on

func _on_windowsill_state_changed(new_state: Windowsill.States) -> void:
	match new_state:
		Windowsill.States.INACTIVE:
			window.interactable.allow_interact = true
		Windowsill.States.EMERGING:
			window.interactable.allow_interact = true
		Windowsill.States.KNOCKING:
			window.interactable.allow_interact = false
		Windowsill.States.STALLING:
			window.interactable.allow_interact = false
		Windowsill.States.JUMPSCARE:
			player.allow_interact = false
			var player_ui = get_tree().get_first_node_in_group("player_ui") as CanvasLayer
			player_ui.hide()
			window.window_anim.play("Jumpscare")

func on_window_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Jumpscare":
		get_tree().change_scene_to_packed(END_SCREEN)

func on_light_toggled(toggle: bool):
	GlobalScript.game_light_on = toggle
	world_environment.environment.volumetric_fog_enabled = toggle
	world_environment.environment.sdfgi_energy = 1 if toggle else 0
	abyss.advance_attack()

func on_lo_stage_changed(new_stage: LightsOut.Stages) -> void:
	flicker_sdfgi = new_stage == LightsOut.Stages.ASSAULT
	GlobalScript.lights_out_is_ready = (
		new_stage == LightsOut.Stages.ANNOUNCEMENT or
		new_stage == LightsOut.Stages.ASSAULT
	)

func sdfgi_flickering() -> void:
	world_environment.environment.sdfgi_energy = randf_range(0.0, 1.0) if GlobalScript.game_light_on else 0.0

func _on_abyss_vapor_jumpscared() -> void:
	shower_progress.value -= randf_range(20, 60)

func on_soap_used() -> void:
	soap_bonus = 2.5

func on_player_killed(killed_by: GlobalScript.MONSTERS) -> void:
	GlobalScript.monster_name = killed_by
	get_tree().change_scene_to_packed(END_SCREEN)
