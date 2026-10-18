shader_type canvas_item;
render_mode unshaded;

// El shader de juego descarta COLOR; este respeta los fundidos del montaje.
varying vec4 sprite_tint;

void vertex() {
	sprite_tint = COLOR;
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	pixel.a = smoothstep(0.13, 0.40, pixel.a);
	COLOR = pixel * sprite_tint;
}
