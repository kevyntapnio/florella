shader_type canvas_item;

uniform float wind_strength = 1.5;
uniform float wind_speed = 3.0;
uniform float sway_offset = 0.0;
uniform float world_y = 0.0;
uniform float blade_offset = 0.0;

void vertex() {
	float time = TIME * wind_speed;
	
	float height_factor = pow(1.0 - UV.y, 1.5);
	
	float wave = sin(time + world_y * 0.03 + blade_offset);
	
	float offset = wave * wind_strength * height_factor;
	
	VERTEX.x += offset;
}