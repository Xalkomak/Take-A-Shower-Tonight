## Attach this node as a child to a PhysicsBody2D/3D to register the parent node as in interactable. Provides a robust set of options to fine-tune your interaction systems within the game world.
class_name Interactable
extends Node

#region Constants
const META_IS_INTERACTABLE := "Interactable" ## Registers the parent node as an interactable component.
const META_COMPONENT_NAME := "InteractableNodeName" ## The name of the child Interactable node that the parent node references from.
const META_HOLD := "Hold" ## Additional data that registers an interactable to be in HOLD mode.
#endregion

enum InteractionMode {
	ONE_SHOT, ## Interacted only once.
	TOGGLE, ## Toggles between two states when interacted with.
	HOLD, ## The action is set to true as long as the interaction button is held.
	ALWAYS, ## The subject can always be interacted with.
}

@export var interaction_mode: InteractionMode ## Set the interaction mode.
@export var interact_prompt: String ## Leave empty if you don't want to display a message.
@export var interact_prompt_toggle: String ## The alternate prompt to display when toggled. Exclusive to TOGGLE mode.
@export var allow_interact: bool = true ## Whether the interactable can be interacted with.
@export var call_method: StringName ## The method to call. If not found, it will print an error message.
@export var delta_threshold: float = 0.2 ## Maximum input delay allowed for HOLD interactions.

var interaction_state: bool = false ## The current state of the interaction. Used by HOLD and TOGGLE modes. It is recommended to use Input.is_action_just_pressed() over Input.is_action_pressed() for HOLD mode.
var parent_node: Node ## Internal reference to the parent node, preferably a PhysicsBody2D or PhysicsBody3D.
var elapsed: float = 0 ## Time elapsed while the "interact" input is pressed before the interaction state becomes active. Used by HOLD mode.

func _ready() -> void:
	parent_node = get_parent()
	register_meta()

func _process(delta: float) -> void:
	if interaction_mode == InteractionMode.HOLD:
		## elapsed starts accumulating when the "interact" input is pressed
		## but no active interaction state has been registered yet.
		if Input.is_action_pressed("interact") and not interaction_state:
			elapsed += delta
		if Input.is_action_just_released("interact"):
			elapsed = 0
		## For HOLD mode, interaction must only be allowed within a certain threshold dictated by delta_threshold
		allow_interact = elapsed <= delta_threshold

## Registers the relevant metadata to this node's parent node.
func register_meta() -> void:
	parent_node.set_meta(META_IS_INTERACTABLE, true)
	parent_node.set_meta(META_COMPONENT_NAME, str(name))
	if interaction_mode == InteractionMode.HOLD: parent_node.set_meta(META_HOLD, true)

## For UI purposes, returns the interaction prompt as a string.
func get_prompt() -> String:
	if allow_interact:
		match interaction_mode:
			InteractionMode.ONE_SHOT, InteractionMode.ALWAYS:
				return interact_prompt
			InteractionMode.TOGGLE:
				return interact_prompt if not interaction_state else interact_prompt_toggle
			InteractionMode.HOLD:
				return interact_prompt if not interaction_state else ""
	return ""

## Processes the interaction event, typically using the _input() function.
func process_interaction_event(toggle: bool = false) -> void:
	if not allow_interact:
		return
	
	match interaction_mode:
		InteractionMode.ONE_SHOT:
			allow_interact = toggle
		InteractionMode.TOGGLE:
			interaction_state = not interaction_state
		InteractionMode.HOLD:
			interaction_state = toggle
			#receiving_input = interaction_state
			parent_node.set_meta(META_HOLD, interaction_state)
		InteractionMode.ALWAYS:
			pass
		_:
			printerr("Interaction mode not recognized or not listed above.")
	
	parent_node.call(call_method) if parent_node.has_method(call_method) else printerr("Warning! Method name '", call_method, "' was not found!")
