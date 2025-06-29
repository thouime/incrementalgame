extends Node

func merge_array(array_one: Array, array_two: Array) -> Array:
	var new_array: Array = array_one.duplicate()
	for item: Variant in array_two:
		if not array_one.has(item):
			new_array.append(item)
	return new_array

func str_to_vector2i(vector_str: String) -> Vector2i:
	var cleaned_str: String = vector_str.replace("(", "").replace(")", "")
	var coords: Array = cleaned_str.split(",")
	var restored_vector := Vector2i(coords[0].to_int(), coords[1].to_int())
	return restored_vector

func get_animation_duration(
	anim_sprite: AnimatedSprite2D, anim_name: String
) -> float:
	var frames : SpriteFrames = anim_sprite.sprite_frames
	if not frames or not frames.has_animation(anim_name):
		printerr("No frames or animation for given animation name!")
		return 0.0
	
	var frame_count : int = frames.get_frame_count(anim_name)
	var fps : float = frames.get_animation_speed(anim_name)
	
	if fps == 0:
		return 0.0
		
	return frame_count / fps
