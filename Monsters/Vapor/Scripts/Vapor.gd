class_name Vapor
extends CanvasLayer

signal jumpscared ## Emitted when Abyss jumpscares the player.

@onready var fade_shader: ShaderMaterial = $VaporNormal.material as ShaderMaterial
@onready var vapor_anim: AnimationPlayer = $VaporAnim

@export var fade_speed: float = 0.2

var is_inactive: bool

func _process(delta: float) -> void:
	if is_inactive: return
	
	if Game.steam_density > 2:
		fade_shader.set_shader_parameter("transparency", 
		fade_shader.get_shader_parameter("transparency") + delta * fade_speed)
	else:
		fade_shader.set_shader_parameter("transparency", 
		fade_shader.get_shader_parameter("transparency") - delta * fade_speed)
	fade_shader.set_shader_parameter("transparency", clamp(
		fade_shader.get_shader_parameter("transparency"), 0, 1
	))
	
	if fade_shader.get_shader_parameter("transparency") >= 1:
		jumpscare()

func jumpscare() -> void:
	vapor_anim.queue("Jumpscare")
	vapor_anim.queue("RESET")
	is_inactive = true
	await get_tree().create_timer(6).timeout
	is_inactive = false
	fade_shader.set_shader_parameter("transparency", 0)
