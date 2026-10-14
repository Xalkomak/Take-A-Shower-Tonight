class_name Displaceable
extends Node3D

@export var random_points: Array[Vector3]

var lights_out: LightsOut
var initial_transform: Transform3D

func _ready() -> void:
	lights_out = get_tree().get_first_node_in_group("Monster_LO") as LightsOut
	lights_out.stage_changed.connect(_on_lights_out_mockup_stage_changed)
	initial_transform = global_transform
	add_to_group("Props", true)

func _on_lights_out_mockup_stage_changed(new_stage: LightsOut.Stages) -> void:
	match new_stage:
		LightsOut.Stages.INACTIVE:
			global_transform = initial_transform
		LightsOut.Stages.SUBTLE:
			pass
		LightsOut.Stages.ANNOUNCEMENT:
			pass
		LightsOut.Stages.ASSAULT:
			pass

func random_transform() -> void:
	if random_points.is_empty():
		return
	global_position = random_points.pick_random()
	rotation.y = randf_range(0.0, 360.0)
