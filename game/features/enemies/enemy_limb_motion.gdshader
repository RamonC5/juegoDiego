shader_type canvas_item;
render_mode unshaded;

uniform int joint_count = 0;
uniform vec2 pivots[8];
uniform vec4 zones[8];
uniform float angles[8];
uniform vec2 source_size = vec2(512.0);
varying vec4 tint;

void vertex() {
	tint = COLOR;
	vec2 rest = UV;
	vec2 displacement = vec2(0.0);
	for (int i = 0; i < joint_count; i++) {
		vec2 local = (rest - zones[i].xy) / zones[i].zw;
		float weight = 1.0 - smoothstep(0.25, 1.0, length(local));
		vec2 relative = rest - pivots[i];
		float s = sin(angles[i]);
		float c = cos(angles[i]);
		vec2 rotated = vec2(c * relative.x - s * relative.y, s * relative.x + c * relative.y);
		displacement += (rotated - relative) * weight;
	}
	VERTEX += displacement * source_size;
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	pixel.a = smoothstep(0.13, 0.40, pixel.a);
	COLOR = pixel * tint;
}
