extends Node2D

@export var mute : bool = false

var current_music : AudioStreamPlayer2D = null
var global_volume : int = 25
var music_volume : int = 25
var sfx_volume : int = 25

@onready var world_music: AudioStreamPlayer2D = $WorldMusic
@onready var menu_music: AudioStreamPlayer2D = $MenuMusic

# Store reference to tween in case it needs to be ended abruptly
var tween: Tween = null

# Function to calculate the final volume in dB
func get_final_volume(volume_percentage: float) -> float:
	
	# Combine global and music volume
	var final_percentage : float = volume_percentage * (global_volume / 100.0) 
	return set_percentage_volume(final_percentage)

func play_music(music_type: String, fade_time: float = 1.0) -> void:
	
	var new_music: AudioStreamPlayer2D = null
	
	match music_type:
		"world":
			new_music = world_music
		"menu":
			new_music = menu_music
	
	if current_music:
		await fade_out_music(current_music, fade_time)
	
	current_music = new_music
	fade_in_music(current_music, fade_time)

func fade_out_music(music: AudioStreamPlayer2D, duration: float) -> void:
	
	if music:
		# Stop existing tween if it exists
		if tween and tween.is_running():
			tween.kill()
			
		tween = create_tween()
		tween.tween_property(music, "volume_db", -40, duration)
		await tween.finished
		music.stop()

func fade_in_music(music: AudioStreamPlayer2D, duration: float) -> void:
	
	if not music:
		return
		
	# Stop existing tween if it exists
	if tween and tween.is_running():
		tween.kill()
		
	# Start playing the music without setting the volume immediately
	music.play()
	
	# Set the initial volume to a very low value (silence)
	music.volume_db = -40
	
	tween = create_tween()
	# Fade in to the target volume
	tween.tween_property(
		music, "volume_db", get_final_volume(music_volume), duration
	)

# Set the global volume
func set_global_volume(new_volume: int) -> void:
	
	global_volume = new_volume
	set_music_volume(music_volume)

# Set the music volume
func set_music_volume(new_volume: int) -> void:
	
	music_volume = new_volume
	if current_music:
		current_music.volume_db = get_final_volume(music_volume)  # Apply the combined volume

# Set the SFX volume
func set_sfx_volume(new_volume: int) -> void:
	
	sfx_volume = new_volume

# Convert percentage to volume in dB
func set_percentage_volume(percentage: float) -> float:
	
	if percentage <= 0:
		return -40 
	var volume_db : float = 20 * log(percentage / 100.0)
	return volume_db
