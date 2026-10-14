class_name LightMechanic
extends StaticBody3D

signal light_toggled(toggle: bool)

@onready var interactable: Interactable = $Interactable
@onready var light_mesh: MeshInstance3D = $Light
@onready var guiding_light: OmniLight3D = $GuidingLight

@export var guiding_light_threshold: float = 5.0

var light_hint_elapsed: float
var light_emit: StandardMaterial3D
var is_on: bool = true

func _ready() -> void:
	light_emit = light_mesh.mesh.surface_get_material(1) as StandardMaterial3D

func _process(delta: float) -> void:
	if GlobalScript.lights_out_is_ready and is_on:
		flicker_light()
	else:
		light_emit.emission_energy_multiplier = 5 if is_on else 0
	
	if is_on:
		light_hint_elapsed = 0
		guiding_light.light_energy = 0
		return
	
	light_hint_elapsed += delta
	if light_hint_elapsed >= guiding_light_threshold:
		guiding_light.light_energy += delta * 0.5
		guiding_light.light_energy = clamp(guiding_light.light_energy, 0, 1.5)

func toggle_light() -> void:
	is_on = not is_on
	light_emit.emission_energy_multiplier = 5 if is_on else 0
	light_toggled.emit(is_on)
	EventBus.game_light_toggled.emit()

func flicker_light() -> void:
	light_emit.emission_energy_multiplier = randf_range(0.2, 5.0)
