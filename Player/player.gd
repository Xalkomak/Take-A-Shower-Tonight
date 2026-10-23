class_name Player
extends MeshInstance3D

@onready var interaction_ray: RayCast3D = $PlayerCam/InteractionRay
@onready var player_cam: Camera3D = $PlayerCam
@onready var prompt_text: RichTextLabel = %PromptText
@onready var pointer: Area3D = %Pointer
@onready var crosshair: ColorRect = $PlayerUI/Crosshair
@onready var soap_blindness_shader: ShaderMaterial = $PlayerUI/SoapBlindness.material as ShaderMaterial

@export var sensitivity: float = 4.0
@export var allow_interact: bool = true

var allow_rotate: bool = true
var soap_effect: float = 0.0

func _ready() -> void:
	EventBus.game_soap_used.connect(on_soap_used)

func _process(delta: float) -> void:
	soap_blindness_shader.set_shader_parameter("soap_amount", clamp(GlobalScript.soap_bonus / 2.5, 0.0, 1.0))
	
	allow_interact = GlobalScript.soap_bonus < 0.2
	crosshair.visible = GlobalScript.soap_bonus < 0.2
	prompt_text.visible = GlobalScript.soap_bonus < 0.2

func _physics_process(delta: float) -> void:
	prompt_text.text = ""
	pointer.global_position = interaction_ray.global_position
	if interaction_ray.is_colliding() and allow_interact:
		var collider = interaction_ray.get_collider()
		if collider.has_meta(Interactable.META_IS_INTERACTABLE): # The object can be interacted with
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

func on_soap_used() -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(set_soap_amount, 0.0, 1.0, 0.2)

func set_soap_amount(value: float) -> void:
	soap_blindness_shader.set_shader_parameter("soap_amount", value)
