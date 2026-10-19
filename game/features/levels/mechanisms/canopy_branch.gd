class_name ForestCanopyBranch
extends ForestPlatform
## Misma colisión unilateral; ramas raster en lugar de bloques de tierra.


func _draw() -> void:
	var texture: Texture2D = RootBridge.TEXTURE
	var source := Rect2(texture.get_size() * Vector2(0.007, 0.26), texture.get_size() * Vector2(0.987, 0.52))
	draw_texture_rect_region(texture, Rect2(0, -10, dimensions.x, dimensions.y + 20), source)
