# Nóctilo · prompts exactos

Fecha: 16 de octubre de 2026. Herramienta: `image_gen` integrada, modo `built_in`. Se solicitó transparencia real en ambas llamadas. No se fijó ni se inventó un seed.

## Referencias y alcance

El concepto es nuevo. Se consultaron el catálogo y las fichas del repositorio; se inspeccionaron visualmente Plumín y Moflete antes de generar. Sus imágenes no se pasaron como referencias a la primera llamada. El acabado se describió en texto. Goterón y Vainete se compararon visualmente durante la revisión. Para Terrón y Remiendo se contrastaron las descripciones del catálogo; no se afirma haber inspeccionado sus PNG en esta entrega.

La especificación detallada de «opción A» no consta en los archivos consultados. El nombre, paleta, personalidad y comportamiento nuevo se registran como propuestas.

## 001 · concepto original

Parámetros: `transparent_background: true`; sin imágenes de entrada.

Salida conservada: [sources/concept_v001.png](sources/concept_v001.png). La revisión técnica detectó píxeles de alfa 1 en el borde inferior (margen mínimo 0 px), ajenos a la silueta visible. No se selecciona como imagen final.

```text
Use case: stylized-concept
Asset type: one isolated high-resolution 2D raster character concept for the side-scrolling platform game Salto Heroes, Android and Windows.
Primary request: Create an original flying normal enemy inspired by a bat. Proposed name: Noctilo (no lettering in the image). Its personality is a nervous, suspicious little night watchman that startles at its own echo. Make its identity come from silhouette, face and acting, not just its color.
Subject and pose: exactly one whole bat, airborne, strictly side-facing RIGHT, fixed side camera suitable for a 2D platformer. Slender tapered suspended torso, compact small head, short projecting wrinkled muzzle, tiny dark nose, one visible NARROW amber eye under an alert raised brow (very little eye white), subtly tense closed mouth. Two very large thin ears; one listens forward, the other angles back. Soft rounded unarmored crown remains visible between their bases. Two broad angular leathery wings with visibly articulated slender finger struts and scalloped membranes, shown in a clearly readable climbing wingbeat, the near wing swept high and backwards and the far wing offset lower behind the body. Keep the silhouette clean with empty space between wings, ears and torso. Two tiny curled feet tucked under the belly, short thin tail. Anatomically coherent BAT wings, not feathered bird wings or extra arms.
Materials and palette: short plush deep aubergine/charcoal fur, muted lavender-gray throat tuft, warm muted COPPER membranes with subtle leathery grain and soft visible folds, dark plum wing struts, natural amber eye. No clothing, props, jewelry, leaf motifs, crystals, armor or glowing effects.
Style/medium: polished HD 2D raster game artwork with tactile fur, soft incorporated volume shading, controlled material detail and crisp softly antialiased silhouette. Same family of rich material treatment as a textured copper-furred woodland rodent and a slate-blue feathered terrestrial bird, but a clearly different creature. Not a flat drawing, comic, ink-outline illustration, pixel art, photoreal wildlife photograph, 3D scene, 3D model or plastic toy render.
Composition/framing: square canvas, single full-body flight pose, centered, all wings/ears/feet/tail entirely inside with generous fully transparent outer padding at least 6 percent on every side. Character fills about 80 percent of canvas width. No pose sheet, duplicates or inset images.
Lighting: soft diffuse upper-left light incorporated into the sprite; restrained edge highlights retain visibility over dark forest and light backgrounds, with no halo.
Background: genuine empty alpha transparency, no floor, environment, ground shadow, backdrop, gradients or drawn checkerboard.
Constraints: Normal enemy intended to be defeated by landing on its head from above: keep soft rounded head and no spikes or horns. Family-friendly mildly mischievous expression, not horror, no gore. No text, labels, watermark, frame, logo, speech bubble, blur or motion trails.
```

## 002 · limpieza de alfa y encuadre

Parámetros: `transparent_background: true`; `referenced_image_paths` contiene exclusivamente la imagen local de la versión 001. Referencia conservada en [sources/concept_v001.png](sources/concept_v001.png).

Salida final: [concept_v002.png](concept_v002.png). Se mantuvo el personaje, la vista lateral y la pose de vuelo; la membrana final presenta un tono algo más cálido. No se modificaron los píxeles del PNG después de generarlo.

```text
Use case: background-extraction
Asset type: production cleanup of an existing transparent 2D bat enemy concept.
Input image 1 is the EDIT TARGET, not just a reference. Preserve this exact bat character, identity, side-facing-right flight pose, anatomy, proportions, aubergine fur, copper membranes, facial expression, wing structure, lighting and detail.
Change ONLY the surrounding alpha cleanup and framing: remove all stray almost-transparent pixels, especially along the bottom border, so that the outside background is entirely alpha ZERO. Keep all character pixels and all wing/ear/foot/tail tips complete. Fit the unchanged entire bat inside the square canvas with at least 6 percent truly empty alpha-zero transparent padding on ALL four edges. No detached dust, wisps, drop shadow, halo, checkerboard, labels, text or background color. Keep its soft antialiased silhouette against genuine transparency. Do not redesign, add limbs, rotate the camera or change pose.
```
