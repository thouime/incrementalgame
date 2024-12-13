shader_type canvas_item;

// RADIAL PROGRESSBAR BY PENGGRIN (<https://github.com/penggrin12>)
// (INTENDED FOR A HEALTH BAR)

// ORIGINAL SHADER: https://www.shadertoy.com/view/WdcGRM
// BY <https://www.shadertoy.com/user/calx>

#define TWO_PI 6.28318530718

uniform vec3 primary_color: source_color = vec3(1.0);
uniform vec3 outline_color: source_color = vec3(0.0);
uniform float value: hint_range(0.0, 1.0, 0.01) = 1.0;

uniform float smooth_ = 0.005;
uniform float width_in = 0.85;
uniform float width_out = 0.95;
uniform float border_width = 0.03;

vec4 radial_progress(vec2 UV_, float VAL, float SMOOTH, float IR, float OR)
{
    vec2 uv = (UV_ * 2.0) - 1.0;
    vec2 origin = vec2(0.0, 0.0);

    float ir = IR;
    float or = OR;
    float d = length(uv);
    float ring = smoothstep(or + SMOOTH, or - SMOOTH, d) - smoothstep(ir + SMOOTH, ir - SMOOTH, d);
    float a = atan(uv.y - origin.y, uv.x - origin.x);  
    float theta = (a < -TWO_PI / 4.0) ? (a + TWO_PI + TWO_PI / 4.0) / TWO_PI : (a + TWO_PI / 4.0) / TWO_PI;
    float bar = step(theta, VAL);
    float ui = ring * bar;

    vec4 colour = vec4(ui);

    return colour;
}

void fragment()
{
    // Calculate the primary color (filled portion)
    vec4 primary = vec4(primary_color, 1.0) * radial_progress(UV, value, smooth_, width_in, width_out);
    
    // Calculate the outline (only show the edges)
    vec4 outline = vec4(outline_color, 1.0) * radial_progress(UV, 100.0, smooth_, width_in - border_width, width_out + border_width);

    // Ensure that the unfilled area is fully transparent and only the outline and filled portion are visible
    if (value == 0.0)
    {
        // Fully transparent when no progress (no outline, no fill)
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
    else
    {
        // Combine the outline and the primary color
        COLOR = primary + outline;  // Outline and primary color together, but nothing in the center
    }
}
