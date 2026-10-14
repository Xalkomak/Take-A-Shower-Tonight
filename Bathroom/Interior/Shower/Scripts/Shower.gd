class_name Shower
extends StaticBody3D

signal shower_toggled(toggled: bool)

const SHOWER = preload("res://Bathroom/Interior/Shower/Materials/Shower.tres")
const SHOWER_GOLD = preload("res://Bathroom/Interior/Shower/Materials/ShowerGold.tres")

@onready var interactable: Interactable = $Interactable
@onready var shower_control: MeshInstance3D = %ShowerControl
@onready var faucet: MeshInstance3D = %Faucet
@onready var shower_knob: MeshInstance3D = %ShowerKnob
@onready var shower_head: MeshInstance3D = %ShowerHead
@onready var water_particles: GPUParticles3D = %WaterParticles
@onready var shower_anim: AnimationPlayer = %ShowerAnim
@onready var shower_audio: AudioStreamPlayer3D = %ShowerAudio

@export var use_golden_shower: bool

var is_shower_on: bool

func _process(delta: float) -> void:
	pass#shower_audio.volume_db = linear_to_db(water_particles.amount_ratio)
	#shower_audio.volume_db = clamp(shower_audio.volume_db, -60, 0)

func _ready() -> void:
	if use_golden_shower:
		shower_control.material_override = SHOWER_GOLD
		faucet.material_override = SHOWER_GOLD
		shower_knob.material_override = SHOWER_GOLD
		shower_head.material_override = SHOWER_GOLD

func toggle_shower() -> void:
	is_shower_on = not is_shower_on
	shower_anim.play("Toggle") if is_shower_on else shower_anim.play_backwards("Toggle")
	#interactable.allow_interact = false
	#shower_audio.playing = is_shower_on
	shower_toggled.emit(is_shower_on)
	EventBus.game_shower_toggled.emit()

func _on_shower_anim_animation_finished(anim_name: StringName) -> void:
	pass#interactable.allow_interact = true
