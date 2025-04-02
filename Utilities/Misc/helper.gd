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
