# Pose de agarre de Diego · 17 de octubre de 2026

Herramienta: `image_gen` integrada; edición con referencia a `game/assets/textures/characters/diego/idle_v001.png`. PNG RGBA con transparencia solicitada y conservada. No se han retocado los píxeles con código. Imagen final en `game/assets/textures/characters/diego/vine_hang_v001.png`; copia de autoría en `vine_hang_source_v001.png`.

## Prompt exacto

```text
Use case: identity-preserve. Asset type: final transparent raster sprite for the existing Godot 2D game Super Diego. Input image is the existing four-pose idle sprite sheet: use it ONLY as the exact identity, outfit, material, proportions, lighting and side-view reference for the SAME boy. Create ONE single full-body hanging pose centered on a square canvas, facing right in the same slight side/three-quarter view. Diego has the identical brown hair, black rectangular glasses, yellow scarf, teal fabric vest with gold buttons, cream short-sleeve shirt, blue cargo shorts and brown hiking boots. Both shoulders raised, both arms reach upward in front of and above his forehead with relaxed slightly bent elbows. Both hands visibly closed around the SAME imaginary thin vertical vine, one hand immediately above the other, knuckles and curved fingers visible; the grip should be a small clearly aligned vertical cluster close to canvas x=50%, about 15% from top. Do NOT draw any vine, rope, knot or prop; the game renders the vine separately through the enclosed hands. The boy's head stays below and slightly to the left of the hands; body weight hangs below the fixed grip, knees softly bent with one boot slightly forward and the other back. Calm focused face. Preserve the exact established boy and outfit; only change the pose. Polished high-resolution textured 2D raster game art, soft consistent warm upper-left lighting, same materials and shading as reference, not flat illustration. Full body and both hands entirely visible, generous transparent margin on every side, empty truly transparent RGBA background. Exactly one character, one pose, no sheet, no text, no labels, no floor, no contact shadow, no border, no extra hands, no vine, no objects.
```

## Integración

1254 × 1254 px; pivote [697, 1137]; punto de agarre [697, 149]; escala 0,12. El shader ya existente elimina alfa residual. La imagen contiene una pose; el balanceo se reproduce alrededor de las manos. `double_jump` reutiliza y reinicia las dos poses existentes de ascenso, sin afirmar que se generó otra hoja.
