shader_type canvas_item;

uniform vec2 Mouse;
uniform float min_intensity;
uniform float max_intensity;
uniform float max_edge;

float inv_lerp_float(in float a, in float b, in float v) {
    return (v - a) / (b - a);
}

vec2 screen_pos(in vec2 fragcoord, in vec2 spsize) {
    return fragcoord/(1.0/spsize);
}

void fragment() {
	vec2 st = screen_pos(FRAGCOORD.xy, SCREEN_PIXEL_SIZE);
	vec3 color = texture(TEXTURE, UV.xy).rgb;
	
	color.r = 0.0;
	color.g = inv_lerp_float(min_intensity, max_intensity, color.g);
	if (
		FRAGCOORD.x <= 1.0 || FRAGCOORD.y <= 1.0 ||
		FRAGCOORD.x >= 2047.0 || FRAGCOORD.y >= 2047.0
	) {
		color.r = 1.0;
		color.b = inv_lerp_float(min_intensity, max_intensity, max_edge);
	}
	
	
	COLOR = vec4(color, 1.0);
}
