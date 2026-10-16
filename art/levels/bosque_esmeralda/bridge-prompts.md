# Arte del puente de raíces · 0.3.0

Se utilizó el modo integrado de `image_gen`, con transparencia real. Referencia de estilo: `game/assets/textures/environments/bosque_esmeralda/forest_props_v001.png`. Los PNG originales se conservan sin editar; Godot realiza el recorte y limita la importación. [Dimensiones, alfa y SHA-256](bridge-art.json).

| Archivo final | Tamaño original | Límite de importación |
| --- | --- | --- |
| `game/assets/textures/environments/bosque_esmeralda/mechanisms/root_bridge_v001.png` | 2172 × 724, RGBA | 1024 px |
| `game/assets/textures/environments/bosque_esmeralda/mechanisms/throw_target_v001.png` | 1254 × 1254, RGBA | 256 px |

## Prompt exacto del puente

```text
Use case: stylized-concept. Asset type: one game-ready horizontal root bridge sprite for an existing polished 2D HD side-scrolling platformer, Salto Heroes. The provided image is a STYLE REFERENCE ONLY: match its detailed brown bark, emerald moss, small leaves, soft golden highlights and rendered raster finish. Generate a brand new single isolated bridge of thick braided tree roots, viewed exactly from the side in orthographic 2D, facing straight along the horizontal axis. A flat mossy top makes a clear walkable line across the full bridge, with interlocking roots and little hanging vine strands underneath. Overall sprite very wide and low, approximately 5:1 aspect in its opaque bounding box. The bridge occupies the horizontal middle, with at least 5% transparent padding around all sides; no scenery, river, cliffs or backdrop. No large supports rising above the walking surface, no perspective vanishing point, no characters, no text, no UI, no watermark, no drop shadow on a background. Actual transparent alpha background. It must read clearly when shown at 500×100 logical pixels. Output as a single sprite, not a mockup or multiple views.
```

## Prompt exacto de la diana

```text
Use case: stylized-concept. Asset type: a single front-facing circular wooden target sprite for the forest mechanism in a polished 2D HD side scrolling platformer. The provided image is STYLE REFERENCE ONLY: use the same detailed brown bark, emerald moss, tiny leaves, softly rendered raster materials and warm golden highlights. Generate a brand new round cross-section of an old tree, seen exactly front-on with perfectly readable concentric light wooden growth rings as a bullseye. Thick uneven bark rim, a few small leaves and moss on the outer rim only. Clear small dark central knot. The circles must remain visible at 112×112 logical pixels and be high contrast natural ivory/tan and dark brown. Centered circular silhouette, occupies approximately 76% of a square canvas with transparent margin on every side. No stand, post, pedestal, mechanism, rope, scenery, character, text, checkmark, UI, watermark, glow or backdrop. Real transparent alpha background. One isolated flat front-facing sprite only, no extra views and no perspective angle.
```

Las imágenes se revisaron dentro de capturas Compatibility del nivel. La colisión del puente y la recepción de la diana se definen mediante formas físicas independientes. La marca de acierto y los rótulos se dibujan en el juego y conservan legibilidad sin sonido. El archivo `qa-bridge-tests.txt` registra las pruebas físicas; la medición en dispositivos reales queda pendiente.
