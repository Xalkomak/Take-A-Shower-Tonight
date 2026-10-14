extends StaticBody3D

@onready var flush_sfx: AudioStreamPlayer3D = %Flush
@onready var flush_timer: Timer = %FlushTimer
@onready var interactable: Interactable = %XDDCC
@onready var flush_water: GPUParticles3D = %FlushWater

func flush() -> void:
	flush_sfx.play()
	flush_water.emitting = true
	flush_timer.start()
	await get_tree().create_timer(4).timeout
	flush_water.emitting = false

func _on_flush_timer_timeout() -> void:
	interactable.allow_interact = true
