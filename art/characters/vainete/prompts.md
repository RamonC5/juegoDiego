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

## Revisión de personalidad · versión 002

Preferencia confirmada el 15 de octubre de 2026: conservar el concepto y reducir el parecido con el resto del reparto. El concepto base está valorado positivamente; esta revisión visual sigue siendo una propuesta.

Herramienta integrada `image_gen`, `transparent_background: true`. Referencia de entrada y versión anterior: [concept_v001.png](concept_v001.png). Se usa la imagen previa de este personaje, no una única cara compartida como referencia para todos. Se conservan concepto y materiales; se revisan silueta, rostro, proporciones y actuación.

### Prompt exacto

```text
Use case: identity-preserve.
Asset type: ONE revised original HD RASTER 2D side-view basic enemy concept for Salto Heroes, Android and Windows.
Input image: the supplied image is THIS CHARACTER'S PRIOR VERSION and material/palette reference. The user LIKES its underlying concept but says the cast looks too similar. This is a SUBSTANTIAL PERSONALITY REDESIGN, not a minor recolor. Preserve ONLY the core creature concept and its characteristic materials/palette; CHANGE the face, proportions, silhouette and acting posture decisively as specified. The old generic giant white angry eye and compact oval body must NOT survive by default.
Rendering: polished textured raster 2D game art with controlled soft tonal shading painted into the bitmap, smooth readable silhouette, restrained fine detail, no comic outlines, no sketch, no pixel art, no 3D model or 3D scene. Soft upper-left light. Keep a coherent world finish, without copying the same facial construction to every creature.
View and composition: strict side-view body facing RIGHT, ONE character and ONE expressive key pose, full body and every limb within the image. Fixed camera at character height, no isometric or three-quarter body view, no turntable, no sprite sheet. Use a square canvas and leave generous empty transparent margin around the entire character including feet and tail.
Background: actual alpha transparency. No ground, external cast shadow, scenery, checkerboard, vignette, text, labels, logos or watermark. Outer border must be fully transparent, free of stray pixels.
Readability: distinctive outline and expression at small mobile size; use shape and posture as well as color. A broad soft or rounded unobstructed upper surface appropriate for defeat by a stomp. No spikes, weapons, sharp armor, gore or exposed teeth.
Specific redesign: REPLACE the giant white eye, thick angry eyebrow and chunky identical root shoes completely. Vainete stays an original THREE-BULGED GREEN SEED POD, now a DISCIPLINED, PROUD, METICULOUS little FOREMAN. Make him EXTRA LONG AND SLENDER horizontally, about three times wider than high, with three softly joined rounded seed bulges, the middle bulge slightly larger. A small blunt right-hand face integrated into the front end, one visible SMALL narrow dark green eye with no white sclera, and TWO PALE VEGETAL FIBERS drooping DOWN beside the small mouth as a tidy little botanical moustache. Not sharp, not rigid, not on top of the head. SIX very THIN flexible ochre root legs with small split root tips, three clearly visible on the near side and the far-side legs mostly hidden. One front leg lifted in a very precise marching step, body held straight and dignified. Soft matte deep pea/sage-green pod skin with long fine botanical veins and a pale lower seam, NO hard shell or armor, no stony cracks. Three broad soft upper bulges remain clear and stompable, no sprouts, weapons or pointed leaves.
```

Salida de esta entrega: [concept_v002.png](concept_v002.png). Resultados reales y límites en [qa.md](qa.md) y [qa-technical.json](qa-technical.json). Los PNG anteriores permanecen conservados y no se retoca la imagen mediante scripts.
