shader_type canvas_item;
render_mode unshaded;

// Recorte suave del alfa residual, conservando la opacidad del HUD y la puerta.
varying vec4 sprite_tint;

void vertex() {
	sprite_tint = COLOR;
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	pixel.a = smoothstep(0.35, 0.60, pixel.a);
	COLOR = pixel * sprite_tint;
}
