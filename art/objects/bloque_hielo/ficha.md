# Bloque de hielo

**Identificador:** `bloque_hielo` · **Estado:** propuesta de diseño integrada en el entrenamiento.

![Bloque de hielo, recurso raster 2D aislado con fondo transparente](../../../game/assets/textures/objects/bloque_hielo/idle_v001.png)

Cae y se desliza por el suelo.

## Arte y lectura

Recurso PNG RGBA de 1254 × 1254, iluminación superior izquierda, materiales con textura y sombreado suave. Importación Godot limitada a 256 × 256; ancho visible propuesto de 42 píxeles. Silueta, material y movimiento distinguen el objeto además del color. La colisión circular de radio 18 píxeles es independiente del alfa.

## Funcionamiento

- Velocidad horizontal de salida: 640 px/s; impulso vertical: 140 px/s.
- Gravedad: 1150 px/s²; lanzamiento activo hasta 4 s, con velocidad mínima de 120 px/s.
- Rebotes máximos: 0; restitución: 0.2.
- El primer receptor consume el lanzamiento. El entrenamiento repone los objetos usados o rotos a los tres segundos y los devuelve si salen del área.
- Recoger y lanzar usa los controles existentes. Soltar un objeto al recibir daño no lo convierte en un ataque.

## Archivos

- [Definición Godot](../../../game/features/objects/definitions/bloque_hielo.tres).
- [Prompt exacto](prompts.md), [encargo](brief.json), [metadatos](object.json).
- [Comprobación técnica](qa-technical.json) y [comprobación estricta de márgenes](qa-strict-margins.json).

## Revisión

Se verificaron lectura RGBA, transparencia, recurso no vacío y comportamiento con la física de Godot 4.7.2. Los originales contienen alfa residual tenue fuera de la figura; el margen estricto de cuatro píxeles del PNG no pasa. La región normalizada y el mismo shader de alfa que utiliza Diego evitan ese borde al dibujarlo. Se conserva el archivo original sin retocar su alfa.

La animación usa la imagen única mediante rotación y, cuando corresponde, compresión breve al rebotar. La vasija se oculta y desactiva su colisión al romperse; no hay una hoja de fragmentos. Las capturas del catálogo y del entrenamiento se registran en [la revisión general](../qa.md). Quedan las pruebas en dispositivos Android y tablet Windows físicos.
