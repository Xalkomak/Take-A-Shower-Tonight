extends Control

@onready var temp_label: Label = $TempLabel

const PEEPING_TOM_DEATH_TIPS: Array[String] = [
	"Check behind the curtains to look for Peeping Tom.",
	"Maintain eye contact with Peeping Tom to scare it away.",
	"Peeping Tom hates being looked at. Use it to your advantage.",
]

const WINDOWSILL_DEATH_TIPS : Array[String] = [
	"Keep the window closed before Windowsill can barge in.",
	"A pair of glowing eyes outside the window signals Windowsill's arrival. Close the window to keep it away.",
]

const WINDOWSILL_BAIT_DEATH_TIPS : Array[String] = [
	"Listen closely. Windowsill only leaves when it knocks exactly thrice.",
	"Make sure Windowsill knocks at the window exactly three times. No more, no less.",
	"Windowsill can bait you into opening the window. It only leaves if it knocks thrice."
]

const LIGHTS_OUT_DEATH_TIPS: Array[String] = [
	"Observe the environment. Displaced objects are a warning sign to turn off the lights on time.",
	"It's in the name. Turn off the lights to keep it at bay.",
	"You don't need to wait to see Lights Out's face to turn off the lights.",
	"Keep the lights off for a few moments."
]

const BURGLAR_DEATH_TIPS: Array[String] = [
	"Knocking on the door is Burglar's warning before entering. Hide and stay quiet.",
	"Turn off the shower and spread the curtain open to hide from Burglar.",
	"Don't interact with anything while Burglar is present.",
]

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	temp_label.text = get_death_tip(GlobalScript.killed_by)

func get_death_tip(killed_by: GlobalScript.KILLED_BY) -> String:
	match killed_by:
		GlobalScript.KILLED_BY.PEEPING_TOM:
			return PEEPING_TOM_DEATH_TIPS.pick_random()
		GlobalScript.KILLED_BY.WINDOWSILL:
			return WINDOWSILL_DEATH_TIPS.pick_random()
		GlobalScript.KILLED_BY.WINDOWSILL_BAIT:
			return WINDOWSILL_BAIT_DEATH_TIPS.pick_random()
		GlobalScript.KILLED_BY.LIGHTS_OUT:
			return LIGHTS_OUT_DEATH_TIPS.pick_random()
		GlobalScript.KILLED_BY.BURGLAR:
			return BURGLAR_DEATH_TIPS.pick_random()
	return ""
