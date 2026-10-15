# Prompts de Moflete

Herramienta integrada `image_gen`, nueva identidad a partir de una referencia de estilo, sin CLI ni seed fijado. Fondo transparente solicitado con `transparent_background: true`.

## Referencia de entrada

[`art/characters/terron/concept_v002.png`](../terron/concept_v002.png), utilizada únicamente para el acabado raster 2D, la iluminación y el tratamiento de materiales. La identidad del nuevo personaje es una propuesta original.

## Prompt exacto de generación

```text
Use case: stylized-concept.
Asset type: single isolated HD RASTER 2D concept for a basic stompable enemy in the original side-view platform game "Salto Heroes", Android and Windows.
Input image: the supplied Terrón image is a STYLE REFERENCE ONLY for material richness, restrained soft tonal shading, polished silhouette and the same side-view light. Create ONLY the new subject described below, never copy Terrón's identity or include Terrón in the output.
Style/medium: finished high-resolution raster 2D game art, richly but selectively textured surfaces, smooth crisp silhouette, soft tonal shading already painted into the 2D bitmap. Similar finish to the reference, with a distinct silhouette. Not a sketch, not flat comic line art, not pixel art, not a 3D model, render or scene.
Camera and pose: strict orthographic SIDE PROFILE FACING RIGHT, ONE complete character in ONE neutral movement key pose, all feet and appendages shown without cropping. Camera at character height. No three-quarter or isometric camera, no rotated view.
Framing: square canvas, character entirely centered within the middle 65 percent of the image. Generous genuinely EMPTY TRANSPARENT MARGINS on all four sides, at least 12 percent each. All pixels in the outer 8 percent border have alpha exactly ZERO. No near-transparent stray flecks outside the silhouette.
Background: real alpha transparency, no colored backdrop or checkerboard pattern. No ground, stage, scenery, floor, external cast shadow or vignette.
Lighting: soft upper-left light, shading attached to the character only.
Readability: broad soft upper surface with no spikes, sharp armor or dangerous-looking protrusions; suitable for elimination by jumping on top. Silhouette and direction must remain clear at 96 pixels on a phone, using shape and value contrast as well as color.
Constraints: original self-contained character. No existing franchise character resemblance, additional characters, labels, names, letters, numbers, logos, signatures or watermarks. No weapons, blood or exposed teeth. Do not create a sprite sheet or multiple poses.
New subject: Small original field-vole-like creature: compact low oval body covered in dense copper-red plush fur, cream cheek and underside, broad blunt round snout, one visible dark eye with an ivory rim. Two very small ROUND ears folded low along the sides, never sticking above the broad rounded back. Two short broad hind feet, tiny front paws held close and visually separate; short rounded tail tucked low behind the body. A cautious determined expression, no teeth.
```


## Primera corrección · versión 002

Herramienta integrada `image_gen`, `transparent_background: true`. Entrada conservada en [sources/concept_v001.png](sources/concept_v001.png). La salida queda conservada como referencia en `sources/concept_v002.png` cuando existe una tercera versión; en otro caso es `concept_v002.png`.

### Prompt exacto

```text
Use case: precise-object-edit. Edit the supplied image of Moflete. Change ONLY framing and empty alpha margins: retain EXACTLY this character, same strict side profile facing RIGHT, same anatomy, colors, materials, eye, lighting, silhouette and neutral pose. Keep the whole body. Put the full character at about 65 percent of the canvas width and height within a square RGBA canvas. Every pixel in the outer 10 percent border on all four sides MUST have alpha exactly zero; remove any near-transparent stray flecks outside the character, especially on the image edges. Genuine transparent background, not black, white, gray or a checkerboard pattern. No floor, no shadow outside the character. Do not introduce extra elements, text or a second pose. This is isolated raster 2D game concept art; no 3D scene. Preserve this identity: Small original field-vole-like creature: compact low oval body covered in dense copper-red plush fur, cream cheek and underside, broad blunt round snout, one visible dark eye with an ivory rim. Two very small ROUND ears folded low along the sides, never sticking above the broad rounded back. Two short broad hind feet, tiny front paws held close and visually separate; short rounded tail tucked low behind the body. A cautious determined expression, no teeth.
```

## Segunda corrección · versión 003

Herramienta integrada `image_gen`, `transparent_background: true`. Entrada conservada en [sources/concept_v002.png](sources/concept_v002.png). Salida seleccionada para esta entrega: [concept_v003.png](concept_v003.png).

### Prompt exacto

```text
Use case: precise-object-edit. In this image of Moflete there are almost invisible stray alpha pixels touching the far LEFT and TOP image borders. Remove all stray pixels outside the visible creature and leave a completely EMPTY TRANSPARENT alpha border at least 64 pixels wide around ALL sides of the artwork, including faint transparent pixels. Keep the visible creature EXACTLY unchanged: same copper fur, cream cheek, low round side ear, ivory eye, two short hind feet and small tucked forepaws, textures, lighting, scale, right-facing side view and pose. The sole requested correction is cleaning the EMPTY OUTSIDE AREA and expanding transparent padding if needed. The outer border must be RGBA alpha 0, not an opaque color, shadow, noise or checkerboard. No new elements, no text. Preserve the entire character and do not crop.
```

El resultado técnico real y los controles pendientes figuran en `qa-technical.json` y `qa.md`. Los PNG se conservan sin retoques mediante scripts.
