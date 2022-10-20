shader_type canvas_item;

uniform vec2 Mouse;
uniform float min_intensity;
uniform float max_intensity;
uniform float max_edge;


vec2 screen_pos(in vec2 fragcoord, in vec2 spsize) {
    return fragcoord/(1.0/spsize);
}

void fragment() {
	vec2 st = screen_pos(FRAGCOORD.xy, SCREEN_PIXEL_SIZE);
	vec3 color = texture(TEXTURE, UV.xy).rgb;
	
	color.r = 0.0;
	float ground = color.b <= color.g ? 0.0 : color.g;
	float water = color.b > color.g ? color.g : 0.0;
	color.b = water;
//	color.g = ground;
	
	COLOR = vec4(color, 1.0);
}
