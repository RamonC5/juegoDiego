# Prompts de Plumín

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
New subject: A small original flightless ground bird, body like a compact rounded PEAR, slightly taller than wide but not slender. Dense short slate-blue feathers with warm pale-ivory chest, one visible ivory-ringed near-black eye, small wide blunt orange beak facing right. Two short orange broad three-toed feet, rounded toes without visible talons. Two small folded wings lying flush on the sides, one wing visible in side profile, a short blunt low tail. The rounded crown is completely smooth with NO crest, tuft, helmet or objects. Calm determined expression. Wings are folded and never flying; this is a basic stompable ground enemy. Broad smooth crown, no spikes. Fine feather texture, no long loose plumage.
```


## Primera corrección · versión 002

Herramienta integrada `image_gen`, `transparent_background: true`. Entrada conservada en [sources/concept_v001.png](sources/concept_v001.png). La salida queda conservada como referencia en `sources/concept_v002.png` cuando existe una tercera versión; en otro caso es `concept_v002.png`.

### Prompt exacto

```text
Use case: precise-object-edit. Edit the supplied image of Plumín. Change ONLY framing and empty alpha margins: retain EXACTLY this character, same strict side profile facing RIGHT, same anatomy, colors, materials, eye, lighting, silhouette and neutral pose. Keep the whole body. Put the full character at about 65 percent of the canvas width and height within a square RGBA canvas. Every pixel in the outer 10 percent border on all four sides MUST have alpha exactly zero; remove any near-transparent stray flecks outside the character, especially on the image edges. Genuine transparent background, not black, white, gray or a checkerboard pattern. No floor, no shadow outside the character. Do not introduce extra elements, text or a second pose. This is isolated raster 2D game concept art; no 3D scene. Preserve this identity: A small original flightless ground bird, body like a compact rounded PEAR, slightly taller than wide but not slender. Dense short slate-blue feathers with warm pale-ivory chest, one visible ivory-ringed near-black eye, small wide blunt orange beak facing right. Two short orange broad three-toed feet, rounded toes without visible talons. Two small folded wings lying flush on the sides, one wing visible in side profile, a short blunt low tail. The rounded crown is completely smooth with NO crest, tuft, helmet or objects. Calm determined expression. Wings are folded and never flying; this is a basic stompable ground enemy. Broad smooth crown, no spikes. Fine feather texture, no long loose plumage.
```

El resultado técnico real y los controles pendientes figuran en `qa-technical.json` y `qa.md`. Los PNG se conservan sin retoques mediante scripts.

## Revisión de personalidad · versión 003

Preferencia confirmada el 15 de octubre de 2026: conservar el concepto y reducir el parecido con el resto del reparto. El concepto base está valorado positivamente; esta revisión visual sigue siendo una propuesta.

Herramienta integrada `image_gen`, `transparent_background: true`. Referencia de entrada y versión anterior: [concept_v002.png](concept_v002.png). Se usa la imagen previa de este personaje, no una única cara compartida como referencia para todos. Se conservan concepto y materiales; se revisan silueta, rostro, proporciones y actuación.

### Prompt exacto

```text
Use case: identity-preserve.
Asset type: ONE revised original HD RASTER 2D side-view basic enemy concept for Salto Heroes, Android and Windows.
Input image: the supplied image is THIS CHARACTER'S PRIOR VERSION and material/palette reference. The user LIKES its underlying concept but says the cast looks too similar. This is a SUBSTANTIAL PERSONALITY REDESIGN, not a minor recolor. Preserve ONLY the core creature concept and its characteristic materials/palette; CHANGE the face, proportions, silhouette and acting posture decisively as specified. The old generic giant white angry eye and compact oval body must NOT survive by default.
Rendering: polished textured raster 2D game art with controlled soft tonal shading painted into the bitmap, smooth readable silhouette, restrained fine detail, no comic outlines, no sketch, no pixel art, no 3D model or 3D scene. Soft upper-left light. Keep a coherent world finish, without copying the same facial construction to every creature.
View and composition: strict side-view body facing RIGHT, ONE character and ONE expressive key pose, full body and every limb within the image. Fixed camera at character height, no isometric or three-quarter body view, no turntable, no sprite sheet. Use a square canvas and leave generous empty transparent margin around the entire character including feet and tail.
Background: actual alpha transparency. No ground, external cast shadow, scenery, checkerboard, vignette, text, labels, logos or watermark. Outer border must be fully transparent, free of stray pixels.
Readability: distinctive outline and expression at small mobile size; use shape and posture as well as color. A broad soft or rounded unobstructed upper surface appropriate for defeat by a stomp. No spikes, weapons, sharp armor, gore or exposed teeth.
Specific redesign: REPLACE the old squat bird ball, giant white eye and angry brow completely. Plumín remains a slate-blue flightless ground bird with ivory chest and muted orange beak/feet, but now he is VAIN, BOASTFUL and THEATRICAL. Give him a LARGE PROUD FORWARD CHEST, a noticeably SMALL ROUND HEAD above a short VISIBLE NECK, and TWO relatively LONG SLENDER orange legs; overall silhouette tall and elegant rather than round. One knee raised high in a theatrical prancing step, the other broad rounded-toe foot supports him. A SMALL folded wing sits on his hip like a proud gesture; no human arms. A SHORT BLUNT beak tilted slightly UPWARD in a pleased smirk, and a TINY near-black eye almost closed into a content curved arc, NO large white sclera, NO angry brow. Tail fans out behind in three short broad rounded feathers. Short dense slate-blue feathers, pale ivory breast, restrained fine plumage. Smooth rounded crown with NO crest, tuft or sharp elements; all toes rounded, no talons. He should look comically self-important and happy with himself.
```

Salida de esta entrega: [concept_v003.png](concept_v003.png). Resultados reales y límites en [qa.md](qa.md) y [qa-technical.json](qa-technical.json). Los PNG anteriores permanecen conservados y no se retoca la imagen mediante scripts.
