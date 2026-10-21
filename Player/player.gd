class_name Player
extends MeshInstance3D

@onready var interaction_ray: RayCast3D = $PlayerCam/InteractionRay
@onready var player_cam: Camera3D = $PlayerCam
@onready var prompt_text: RichTextLabel = %PromptText
@onready var pointer: Area3D = %Pointer

@export var sensitivity: float = 4.0
@export var allow_interact: bool = true

var allow_rotate: bool = true

func _physics_process(delta: float) -> void:
	prompt_text.text = ""
	pointer.global_position = interaction_ray.global_position
	if interaction_ray.is_colliding() and allow_interact:
		var collider = interaction_ray.get_collider()
		if collider.has_meta(Interactable.META_NAME): # The object can be interacted with
			handle_interactable(collider)
		
		if collider is Area3D:
			pointer.global_position = interaction_ray.get_collision_point()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and allow_rotate:
		rotate_y(-event.relative.x / 1000 * sensitivity)
		player_cam.rotate_x(-event.relative.y / 1000 * sensitivity)
		player_cam.rotation.x = clamp(player_cam.rotation.x, deg_to_rad(-80), deg_to_rad(90))

func handle_interactable(collider: Object) -> void:
	var interactable: Interactable = collider.get_node(collider.get_meta(Interactable.META_COMPONENT_NAME))
	prompt_text.text = "[center]" + interactable.get_prompt() + "[/center]"
	
	if Input.is_action_just_pressed("interact"):
		if collider.has_meta(Interactable.META_HOLD): #Special case for Hold type interaction
			interactable.process_interaction_event(true)
			allow_rotate = false # Set to true or remove this line if you want the player to rotate, but this is prone to breaking the interaction system
		else:
			interactable.process_interaction_event()
		
	if Input.is_action_just_released("interact"):
		allow_rotate = true
		if collider.has_meta(Interactable.META_HOLD):
			interactable.process_interaction_event(false)
