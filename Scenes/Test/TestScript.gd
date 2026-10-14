extends Node3D

@onready var pointer: MeshInstance3D = $Pointer
@onready var sphere_checker: MeshInstance3D = $SphereChecker
@onready var cube_checker: MeshInstance3D = $CubeChecker
@onready var plane_checker: MeshInstance3D = $PlaneChecker
@onready var camera_3d: Camera3D = $Camera3D

var vector_rng: VectorRNG = VectorRNG.new()

func _ready() -> void:
	if sphere_checker.visible:
		var point_in_sphere = vector_rng.rand_inside_unit_sphere(sphere_checker.global_position, \
		sphere_checker.mesh.get("radius"))
		pointer.global_position = point_in_sphere
	elif cube_checker.visible:
		var point_in_cube = vector_rng.rand_inside_unit_cube(cube_checker.global_position, \
		cube_checker.mesh.get("size"))
		pointer.global_position = point_in_cube
	elif plane_checker.visible:
		var point_on_plane = vector_rng.rand_on_unit_plane(plane_checker.global_position, \
		plane_checker.mesh.get("size"))
		pointer.global_position = point_on_plane
