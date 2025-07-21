shader_type canvas_item;

uniform bool enabled = true;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (enabled) {
		float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
		tex_color = vec4(vec3(gray), tex_color.a * 0.5); // Greyscale and semi-transparent
	}

	COLOR = tex_color;
}