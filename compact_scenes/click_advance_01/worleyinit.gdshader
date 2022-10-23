shader_type canvas_item;


uniform float grid = 128.0;

vec2 random2( vec2 p ) {
	return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void fragment() {
	// Tile the space
	vec2 st = UV * grid;
	vec2 i_st = floor(st); // Tile col and row
	vec2 f_st = fract(st); // Position within the tile

	// Random position from current + neighbor place in the grid
	vec2 point = random2(i_st);

	// Vector between the pixel and the point
	vec2 diff = point - f_st;

	// Distance to the point
	float dist = length(diff);
	
	// Draw 1 or 2 cells at the center
	vec3 color = vec3(step(dist, grid / 2048.0));
	color.rg = step(1.0, color.b) * UV;

	COLOR = vec4(color,1.0);
}