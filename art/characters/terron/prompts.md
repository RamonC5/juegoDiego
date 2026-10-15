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

