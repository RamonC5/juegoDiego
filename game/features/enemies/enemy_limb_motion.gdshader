shader_type canvas_item;
render_mode unshaded;

// Articulaciones en UV del PERSONAJE recortado; el raster sigue en UV del atlas.
uniform int joint_count = 0;
uniform vec2 pivots[8];
uniform vec4 zones[8];
uniform float angles[8];
uniform vec2 translations[8];
uniform vec2 source_size = vec2(512.0);
uniform vec2 region_origin = vec2(0.0);
uniform vec2 region_extent = vec2(1.0);
varying vec4 tint;

void vertex() {
	tint = COLOR;
	vec2 rest = (UV - region_origin) / max(region_extent, vec2(0.00001));
	vec2 displacement = vec2(0.0);
	// Recuento constante: más compatible con los controladores OpenGL ES de Android.
	for (int i = 0; i < 8; i++) {
		if (i >= joint_count) {
			break;
		}
		vec2 local = (rest - zones[i].xy) / max(zones[i].zw, vec2(0.00001));
		float weight = 1.0 - smoothstep(0.30, 1.08, length(local));
		vec2 relative = rest - pivots[i];
		float s = sin(angles[i]);
		float c = cos(angles[i]);
		vec2 rotated = vec2(c * relative.x - s * relative.y, s * relative.x + c * relative.y);
		displacement += ((rotated - relative) + translations[i]) * weight;
	}
	VERTEX += displacement * region_extent * source_size;
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	pixel.a = smoothstep(0.13, 0.40, pixel.a);
	COLOR = pixel * tint;
}
