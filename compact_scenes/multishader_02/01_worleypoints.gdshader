shader_type canvas_item;

vec2 random2( vec2 p ) {
	return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void fragment() {
	vec2 st = UV * 10.0;

	vec3 color = vec3(.0);

	// Tile the space
	vec2 i_st = floor(st);
	vec2 f_st = fract(st);

	// Random position from current + neighbor place in the grid
	vec2 point = random2(i_st);

	// Vector between the pixel and the point
	vec2 diff = point - f_st;

	// Distance to the point
	float dist = length(diff);
	
	// Draw 1 or 2 cells at the center
	color += step(dist, 0.0025);
	
	// Set red and green of a point to the x and y
	color.r = step(dist, 0.0025) * UV.x;
	color.g = step(dist, 0.0025) * UV.y;


	COLOR = vec4(color,1.0);
}