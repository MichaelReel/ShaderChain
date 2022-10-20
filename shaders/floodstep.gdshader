shader_type canvas_item;

uniform vec2 Mouse;
uniform float min_intensity;
uniform float max_intensity;

bool red_nearby(vec2 uv, vec2 sps, sampler2D tex) {
	for (float y = uv.y - sps.y; y <= uv.y + sps.y; y += sps.y) {
		for (float x = uv.x - sps.x; x <= uv.x + sps.x; x += sps.x) {
			float flag = texture(tex, vec2(x, y)).r;
			if (flag >= 1.0) {
				return true;
			}
		}
	}
	return false;
}

bool lowest_pending_nearby(vec2 uv, vec2 sps, sampler2D tex) {
	float lowest = texture(tex, uv).r;
	for (float y = uv.y - sps.y; y <= uv.y + sps.y; y += sps.y) {
		for (float x = uv.x - sps.x; x <= uv.x + sps.x; x += sps.x) {
			vec3 color = texture(tex, vec2(x, y)).rgb;
			float flag = color.r;
			if (flag < 1.0) {
				if (lowest > color.g && uv.x != x && uv.y != y) {
					return false;
				}
			}
		}
	}
	return true;
}

float max_blue_processed_nearby(vec2 uv, vec2 sps, sampler2D tex) {
	float max_blue = texture(tex, uv).g;
	for (float y = uv.y - sps.y; y <= uv.y + sps.y; y += sps.y) {
		for (float x = uv.x - sps.x; x <= uv.x + sps.x; x += sps.x) {
			float flag = texture(tex, vec2(x, y)).r;
			if (flag >= 1.0) {
				max_blue = max(texture(tex, vec2(x, y)).b, max_blue);
			}
		}
	}
	return max_blue;
}

vec2 screen_pos(in vec2 fragcoord, in vec2 spsize) {
    return fragcoord/(1.0/spsize);
}

void fragment() {
	vec2 st = screen_pos(FRAGCOORD.xy, SCREEN_PIXEL_SIZE);
	vec3 color = texture(TEXTURE, UV.xy).rgb;
	
	float flag = color.r;
	float water_depth = color.b;
	float ground_depth = color.g;
	
	// Yikes, branching - consider refactoring this
	if (flag < 1.0) {
		if (flag >= 0.5) {
			// Set blue to the largest water_depth (blue) of fully flag (red) points nearby
			// Or the current ground height, if that's higher.
			color.b = max_blue_processed_nearby(UV.xy, SCREEN_PIXEL_SIZE, TEXTURE);
			// Flag this pixel as processed (in the red channel)
			color.r = 1.0;
		} else {
			// If there is a fully flagged (red) point nearby, set this to half-flagged (pink)
			if (red_nearby(UV.xy, SCREEN_PIXEL_SIZE, TEXTURE)) {
				if (lowest_pending_nearby(UV.xy, SCREEN_PIXEL_SIZE, TEXTURE)) {
					color.r = 0.5;
				}
			}
		}
	}
	COLOR = vec4(color, 1.0);
}
