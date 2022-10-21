shader_type canvas_item;

bool bunched(vec2 uv, vec2 sps, sampler2D tex) {
	vec2 up = vec2(0.0, -1.0) * sps;
	vec2 left = vec2(-1.0, 0.0) * sps;
	float up_blue = texture(tex, uv + up).b;
	float left_blue = texture(tex, uv + left).b; 
	if (step(0.5, up_blue) > 0.5) return true;
	if (step(0.5, left_blue) > 0.5) return true;
	return false;
}

void fragment() {
	// Remove extra pixels from pixels that are bunched together
	vec3 color = texture(TEXTURE, UV).rgb;
	
	float blue = color.b;
	if (step(0.5, blue) > 0.5 && bunched(UV, SCREEN_PIXEL_SIZE, TEXTURE)) {
		color = vec3(0.0);
	}

	COLOR = vec4(color,1.0);
}