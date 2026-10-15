# Prompts de Vainete

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
New subject: An original walking seed-pod creature, horizontally elongated and low. A single soft matte sage-green seed pod with THREE broad smoothly rounded bulges joined into one continuous body, no sharp ridges. A blunt small head integrated into the right-hand front end, one ivory eye and dark pupil. Three short warm ochre root feet visible along the near side, with corresponding far-side feet mostly hidden: six feet total, no extra legs. The upper ridge is rounded and unobstructed, with no leaves or sprouts sticking upward. A soft botanical satin texture with fine controlled longitudinal fibers and a pale seam along the lower side. No hard shell, no armor, no thorns, no open pod or exposed seeds. Expression alert and mildly stubborn.
```

