extends Control

@onready var temp_label: Label = $TempLabel

const PEEPING_TOM_DEATH_TIPS: Array[String] = [
	"Check behind the curtains to look for Peeping Tom.",
	"Maintain eye contact with Peeping Tom to scare it away.",
	"Peeping Tom hates being looked at. Use it to your advantage.",
]

const LIGHTS_OUT_DEATH_TIPS: Array[String] = [
	"Observe the environment. Displaced objects are a warning sign to turn off the lights on time.",
	"It's in the name. Turn of the lights to keep it at bay."
]

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
