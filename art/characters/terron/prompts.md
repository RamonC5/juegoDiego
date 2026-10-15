# Prompt de Terrón · versión 001

Generación con la herramienta integrada `image_gen`; imagen nueva sin referencias de entrada. Diseño propuesto, no seleccionado todavía por el usuario. Fondo transparente solicitado con `transparent_background: true`. No se fija un seed.

## Primera generación · referencia histórica

Imagen conservada en `sources/concept_v001.png`. Falló el control de margen; no es la referencia seleccionada para producción.

### Prompt exacto

```text
Use case: stylized-concept.
Asset type: single isolated HD raster 2D side-view character concept for the original mobile and Windows platform game "Salto Heroes".
Primary request: design the FIRST basic enemy, proposed name Terrón. One original small walking earth-and-moss creature, low and wide, with a softly rounded compact irregular earthen body, a broad gently flattened cushion of short moss across its upper back, a small blunt forward face with one clearly readable ivory eye and dark pupil, no arms, two short thick root-like feet. Feet form a readable walking silhouette. The upper moss surface is wide, soft and unobstructed, visually readable as a safe stomp target; do not put any pointed shapes or objects on its head. Slightly grumpy and determined, playful rather than frightening. Avoid resemblance to existing famous videogame enemies.
Style/medium: premium finished high-resolution RASTER 2D game art, polished richly textured surfaces and controlled soft tonal shading painted into the 2D image, crisp smooth silhouette, clear large shapes readable at 96 px on a phone. Not flat cartoon, not line art, not a comic drawing, not pixel art, not a 3D scene or 3D model render.
Scene/backdrop: genuinely transparent alpha background, absolutely no ground, stage, scenery, drop shadow or lighting vignette outside the character.
Composition/framing: just ONE character and ONE neutral patrol key pose. Strict SIDE PROFILE facing RIGHT, camera at the height of the character, orthographic side view, no three-quarter or isometric camera, show complete body and both feet without cropping. Center within a square image and leave generous transparent margin on all four sides (about 12%). No sprite sheet or multiple poses.
Lighting: soft consistent light from upper left; shading stays attached to the character.
Materials/textures: warm ochre terracotta earth with restrained fine grain and a few broad softly rounded surface fissures; short dense velvety green moss cap. No shiny armor or hard carapace. No vegetation sticking up.
Palette: earthy ochre body, deep brown root feet, muted fresh moss green on top, pale ivory eye with near-black pupil. Use form and value contrast to distinguish the top and feet.
Constraints: original enemy concept for a purely 2D game. No 3D assets. No costume, tools, weapons, horns, spikes, exposed teeth, blood, other characters, mushrooms, turtle shell, labels, text, signature, watermark, checkerboard pattern or colored background. Preserve clean real alpha transparency.
```

## Corrección y versión seleccionada

Herramienta integrada `image_gen`, modo de edición, `transparent_background: true`. Entrada: la primera generación, conservada en `sources/concept_v001.png`. Salida seleccionada: `concept_v002.png`. La ruta local de entrada durante la llamada era `art/characters/terron/concept_v001.png`; se trasladó a `sources/` al organizar el entregable.

### Prompt exacto

```text
Use case: precise-object-edit. Edit the supplied image of Terrón. Change ONLY framing and the empty alpha margins: retain exactly this character, same side-profile facing right, earthen ochre body, short green moss cap, one ivory eye and two root feet, texture, lighting, silhouette and neutral pose. Keep complete body. Put the full character at about 65 percent of the canvas width and height within a square RGBA canvas. Every pixel in the outer 10 percent border on all four sides MUST have alpha exactly zero; remove any near-transparent stray flecks outside the character, especially on the image edges. Genuine transparent background, not black, white, gray or a checkerboard pattern. No floor, no shadow outside the character. Do not introduce extra elements, text or a second pose. This is isolated raster 2D game concept art; no 3D scene.
```

El resultado técnico real figura en `qa-technical.json`. No se ha redimensionado, recortado ni retocado el PNG con scripts.

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
Specific redesign: REPLACE the old round angry face and giant white eye completely. Terrón stays an original earth-and-moss creature, but now he is SLEEPY, HEAVY and STUBBORN. Make an exceptionally LOW WIDE LOPSIDED EARTHEN BLOCK, a softened rectangular body about 2.3 times wider than tall, with a broad flattened moss cushion, heavier rear mass and a small forward earth cheek. One visible TINY half-closed amber eye, narrow sleepy eyelid, almost no white sclera; the eye is a minor detail rather than a focal giant eye. A short crooked relaxed mouth and a drooping clay cheek, no heavy angry brow. Two short wide flat earthen root pads barely lift the body, not rounded shoe-like toes. Posture slumped low, weight back, chin down, as if pausing before a slow stubborn step. Warm ochre earth, restrained broad cracks and fine grain, short soft moss with uneven LOW patches. His top is broad, flattened, soft and clear of anything pointed. Keep a distinctly horizontal rectangular silhouette.
```

Salida de esta entrega: [concept_v003.png](concept_v003.png). Resultados reales y límites en [qa.md](qa.md) y [qa-technical.json](qa-technical.json). Los PNG anteriores permanecen conservados y no se retoca la imagen mediante scripts.
