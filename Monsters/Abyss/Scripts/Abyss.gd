class_name Abyss
extends CanvasLayer

signal jumpscared ## Emitted when Abyss jumpscares the player.

@onready var abyss_audio_cue: AudioStreamPlayer = $AbyssAudioCue
@onready var jumpscare_face: TextureRect = $JumpscareFace
@onready var sample_hz: int = $AbyssAudioCue.stream.mix_rate
@onready var abyss_anim: AnimationPlayer = $AbyssAnim

@export var approach_rate: float = 8.0

var playback: AudioStreamGeneratorPlayback
var pulse_hz: float = 440.0
var initial_vol: float = -80.0

func _ready() -> void:
	abyss_audio_cue.volume_db = initial_vol
	advance_attack()

func advance_attack() -> void:
	set_process(not GlobalScript.game_light_on)
	abyss_audio_cue.playing = not GlobalScript.game_light_on
	if not GlobalScript.game_light_on:
		playback = abyss_audio_cue.get_stream_playback()
		fill_buffer()
	else:
		abyss_audio_cue.volume_db = initial_vol

func _process(delta: float) -> void:
	abyss_audio_cue.volume_db += delta * approach_rate
	if abyss_audio_cue.volume_db > 0:
		abyss_audio_cue.volume_db = initial_vol
		jumpscare_player()

func fill_buffer() -> void:
	var phase := 0.0
	var increment := pulse_hz / sample_hz
	var frames_available := playback.get_frames_available()
	var voc := 0.0
	
	for i in range(frames_available):
		voc += get_process_delta_time() * 0.4
		playback.push_frame(Vector2.ONE * (phase / 2 * randf_range(0.3, 60)))
		phase = fmod(phase + increment * 0.4, cos(2))

func _on_abyss_audio_cue_finished() -> void:
	if not GlobalScript.game_light_on:
		abyss_audio_cue.play()
		playback = abyss_audio_cue.get_stream_playback()
		fill_buffer()

func jumpscare_player() -> void:
	approach_rate = 0
	abyss_anim.play("Jumpscare")
	jumpscared.emit()
	await get_tree().create_timer(6).timeout
	abyss_anim.play("RESET")
	approach_rate = 8
