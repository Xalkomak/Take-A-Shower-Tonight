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

func _ready() -> void:
	shower_anim.speed_scale = 1
	EventBus.player_jumpscared.connect(on_player_jumpscared)
	if use_golden_shower:
		shower_control.material_override = SHOWER_GOLD
		faucet.material_override = SHOWER_GOLD
		shower_knob.material_override = SHOWER_GOLD
		shower_head.material_override = SHOWER_GOLD

func toggle_shower() -> void:
	is_shower_on = not is_shower_on
	shower_anim.play("Toggle") if is_shower_on else shower_anim.play_backwards("Toggle")
	shower_toggled.emit(is_shower_on)
	EventBus.game_shower_toggled.emit()

func on_player_jumpscared(jumpscared_by: GlobalScript.KILLED_BY):
	if jumpscared_by != GlobalScript.KILLED_BY.NONE:
		shower_anim.speed_scale = 10
		shower_anim.play_backwards("Toggle")
