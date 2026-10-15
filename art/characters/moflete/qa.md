# Revisión de personalidad de Moflete

Fecha: **15 de octubre de 2026**. Alcance: concepto 2D estático, versión 004.

## Revisión solicitada y referencia

El usuario valora el concepto de criatura y pide más personalidad y menor parecido entre personajes. Se contrasta esta revisión con [concept_v003.png](concept_v003.png) y con las otras cinco nuevas imágenes del catálogo.

## Revisión visual realizada

Se inspeccionaron imagen completa, comparación del reparto a tamaño reducido y lectura sobre fondo claro (#fffdf8) y oscuro (#111e29), sin modificar el PNG original.

- Conserva pelaje cobrizo y mejilla crema, con tronco estrecho, postura erguida y mejilla muy abultada.
- Ojo oscuro redondo, boca abierta y manos cerca de la cara comunican curiosidad sin el ceño anterior.
- Cola curva y patas en puntillas lo distinguen del pecho y paso de Plumín y de la postura retraída de Remiendo.
- Silueta, dirección y expresión legibles en la vista reducida sobre fondos claro y oscuro.

## Comprobación técnica

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/moflete/concept_v004.png
```

Resultado: **Pendiente el margen de producción**, código de salida 1. La imagen es RGBA y tiene fondo transparente, pero el comprobador detecta alfa residual hasta el borde. Se conserva como concepto, sin declararlo sprite preparado. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Fotogramas | 1, imagen estática |
| Límites con alfa no nulo | [0, 21, 1244, 1254] |
| Margen mínimo | 0 px; referencia para producción: 4 px |
| Peso | 904805 bytes |
| SHA-256 | `22575d3a14057c2ebdcb68384f575f18ebfa453e75fc82bb178f78b099fe540f` |

## Pendiente

Valorar esta revisión visual con el usuario, incorporar la referencia completa de «opción A», preparar celdas y pivote, producir animaciones e integrar los recursos. Las descripciones de gestos son propuestas de animación; no se han producido sus secuencias ni probado Godot, Android o Windows.

Estado: **concept_only**. La aprobación del concepto base no equivale a una selección de esta imagen nueva.
