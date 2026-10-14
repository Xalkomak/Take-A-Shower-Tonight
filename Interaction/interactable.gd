class_name Interactable
extends Node

#region Constants
const META_NAME := "Interactable"
const META_COMPONENT_NAME := "InteractableNodeName"
const META_SWITCH := "Switch"
const META_HOLD := "Hold"
const META_ONESHOT := "Oneshot"
#endregion

enum InteractionMode {
	ONE_SHOT, ## Interacted only once.
	TOGGLE, ## Toggles between two states when interacted with.
	HOLD, ## The action is set to true as long as the interaction button is held.
	ALWAYS, ## The subject can always be interacted with.
}

@export var interaction_mode: InteractionMode ## Set the interaction mode.
@export var interact_prompt: String ## Leave empty if you don't want to display a message.
@export var interact_prompt_toggle: String ## The propmpt to display when toggled. Exclusive to Toggle mode.
@export var allow_interact: bool = true ## Whether the interactable can be interacted with.
@export var call_method: StringName ## The method to call. If not found, it will print an error message.
@export var delta_threshold: float = 0.2 ## How long before the component refuses to process interaction.

var is_toggled: bool = false
var is_held: bool
var parent_node: Node
var component_name: String
var elapsed: float = 0
var receiving_input: bool

func _ready() -> void:
	parent_node = get_parent()
	register_meta()

func _process(delta: float) -> void:
	if interaction_mode == InteractionMode.HOLD:
		if Input.is_action_pressed("interact") and not receiving_input:
			elapsed += delta
		if Input.is_action_just_released("interact"):
			elapsed = 0
		allow_interact = elapsed <= delta_threshold

func register_meta() -> void:
	parent_node.set_meta(META_NAME, true)
	parent_node.set_meta(META_COMPONENT_NAME, str(name))
	
	match interaction_mode:
		InteractionMode.TOGGLE:
			parent_node.set_meta(META_SWITCH, false)
		InteractionMode.HOLD:
			parent_node.set_meta(META_HOLD, true)

func get_prompt() -> String:
	if allow_interact:
		match interaction_mode:
			InteractionMode.ONE_SHOT:
				return interact_prompt
			InteractionMode.TOGGLE:
				return interact_prompt if not is_toggled else interact_prompt_toggle
			InteractionMode.HOLD:
				return interact_prompt if not is_held else ""
			InteractionMode.ALWAYS:
				return interact_prompt
	return ""

func process_interaction_event(toggle: bool = false) -> void:
	if not allow_interact:
		return
	
	match interaction_mode:
		InteractionMode.ONE_SHOT:
			allow_interact = toggle
		InteractionMode.TOGGLE:
			is_toggled = not is_toggled
			parent_node.set_meta(META_SWITCH, is_toggled)
		InteractionMode.HOLD:
			is_held = toggle
			receiving_input = is_held
			parent_node.set_meta(META_HOLD, is_held)
		InteractionMode.ALWAYS:
			pass
		_:
			printerr("Interaction mode not recognized or not listed above.")
	
	if parent_node.has_method(call_method):
		var method = parent_node.call(call_method)
	else:
		printerr("Warning! Method name '", call_method, "' was not found!")
		return 
