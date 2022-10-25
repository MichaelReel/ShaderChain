shader_type canvas_item;

uniform float min_height = 0.0;
uniform float max_height = 1.0;

void fragment(){
	vec2 uv = UV;
	
	// All channels should be the same
	float red = texture(TEXTURE, uv).r;
	float f = smoothstep(min_height, max_height, red);
	
	COLOR = vec4(vec3(f), 1.0);
}