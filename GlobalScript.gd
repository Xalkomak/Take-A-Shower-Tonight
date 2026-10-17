extends Node

enum MONSTERS {
	PEEPING_TOM,
	WINDOWSILL,
	LIGHTS_OUT,
	BURGLAR
}
var monster_name: MONSTERS

var is_fullscreen: bool

var game_window_closed: bool
var game_shower_on: bool
var game_curtain_open: bool
var game_light_on: bool = true

var lights_out_is_ready: bool

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_screensize") and OS.is_debug_build():
		is_fullscreen = not is_fullscreen
		if is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
