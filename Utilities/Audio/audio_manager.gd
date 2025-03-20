extends Node2D


@export var mute : bool = false

var current_music : AudioStreamPlayer2D = null
var global_volume : int = 25
var music_volume : int = 25
var sfx_volume : int = 25

@onready var world_music: AudioStreamPlayer2D = $WorldMusic
@onready var menu_music: AudioStreamPlayer2D = $MenuMusic

func play_music(music_type: String, fade_time: float = 1.0):
	
	var new_music: AudioStreamPlayer2D = null
	
	match music_type:
		"world":
			new_music = world_music
		"menu":
			new_music = menu_music
		_:
			null

	if current_music:
		fade_out_music(current_music, fade_time)
	
	current_music = new_music
	fade_in_music(current_music, fade_time)
	
func fade_out_music(music: AudioStreamPlayer2D, duration: float):
	
	if music:
		var tween = create_tween()
		tween.tween_property(music, "volume_db", -40, duration)
		tween.tween_callback(music.stop)

func fade_in_music(music: AudioStreamPlayer2D, duration: float):
	
	if not music:
		return
		
	music.volume_db = -40 # Start muted
	music.play()
	
	var tween = create_tween()
	tween.tween_property(music, "volume_db", 0, duration)

func set_global_volume(new_volume: int) -> void:
	global_volume = new_volume
	set_music_volume(new_volume)
	
func set_music_volume(new_volume: int) -> void:
	music_volume = new_volume
	if current_music:
		current_music.volume_db = set_percentage_volume(music_volume)
	
func set_sfx_volume(new_volume: int) -> void:
	sfx_volume = new_volume

func set_percentage_volume(percentage: float) -> float:
	var volume_db = 20 * log(percentage / 100.0)
	return volume_db
