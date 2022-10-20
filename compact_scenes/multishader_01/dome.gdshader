shader_type canvas_item;
uniform float x_shape;
uniform float depth;

vec2 square_pos(in vec2 fragcoord, in vec2 spsize, in float ratio) {
    vec2 res = 1.0/spsize;
    vec2 st = fragcoord/res;
    st.x *= res.x/res.y * ratio;
    return st;
}

void fragment() {
	vec2 st = square_pos(FRAGCOORD.xy, SCREEN_PIXEL_SIZE, 1.0);
	vec3 color = texture(TEXTURE, UV.xy).rgb;
	
	// Circular, around the middle
	float cf = clamp((1.0 - depth) - distance(st, vec2(0.5)), 0.0, 1.0);

	// Find the nearest edges
	float vert = step(0.5, st.y);
	float hort = step(0.5, st.x);
	float sf = min(abs(vert - st.y), abs(hort - st.x)) + 0.5 - depth;

	float f = mix(cf, sf, x_shape);
	
	vec3 fade = vec3(f);
	
	color = (color * fade + fade * 1.5) - 0.55;
		
	COLOR = vec4(color, 1.0);
}
