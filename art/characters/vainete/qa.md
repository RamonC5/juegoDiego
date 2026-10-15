# Revisión de personalidad de Vainete

Fecha: **15 de octubre de 2026**. Alcance: concepto 2D estático, versión 002.

## Revisión solicitada y referencia

El usuario valora el concepto de criatura y pide más personalidad y menor parecido entre personajes. Se contrasta esta revisión con [concept_v001.png](concept_v001.png) y con las otras cinco nuevas imágenes del catálogo.

## Revisión visual realizada

Se inspeccionaron imagen completa, comparación del reparto a tamaño reducido y lectura sobre fondo claro (#fffdf8) y oscuro (#111e29), sin modificar el PNG original.

- Conserva la vaina de tres volúmenes y los apoyos vegetales, ahora finos y más elevados.
- La mirada verde pequeña y el bigote de fibras vegetales dan un rostro propio, distinto de Terrón.
- Una raíz delantera levantada y el cuerpo horizontal comunican marcha medida y porte disciplinado.
- Silueta segmentada reconocible en reducción; bigote y apoyos completos, sin elementos punzantes en el lomo.

## Comprobación técnica

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/vainete/concept_v002.png
```

Resultado: **Pendiente el margen de producción**, código de salida 1. La imagen es RGBA y tiene fondo transparente, pero el comprobador detecta alfa residual hasta el borde. Se conserva como concepto, sin declararlo sprite preparado. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Fotogramas | 1, imagen estática |
| Límites con alfa no nulo | [0, 33, 1234, 1244] |
| Margen mínimo | 0 px; referencia para producción: 4 px |
| Peso | 889739 bytes |
| SHA-256 | `e93e51b7b2d90794f79c74d227e497aa3ed0a128c16b66bcaf8a4aae0095452c` |

## Pendiente

Valorar esta revisión visual con el usuario, incorporar la referencia completa de «opción A», preparar celdas y pivote, producir animaciones e integrar los recursos. Las descripciones de gestos son propuestas de animación; no se han producido sus secuencias ni probado Godot, Android o Windows.

Estado: **concept_only**. La aprobación del concepto base no equivale a una selección de esta imagen nueva.
