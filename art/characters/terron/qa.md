# Revisión de personalidad de Terrón

Fecha: **15 de octubre de 2026**. Alcance: concepto 2D estático, versión 003.

## Revisión solicitada y referencia

El usuario valora el concepto de criatura y pide más personalidad y menor parecido entre personajes. Se contrasta esta revisión con [concept_v002.png](concept_v002.png) y con las otras cinco nuevas imágenes del catálogo.

## Revisión visual realizada

Se inspeccionaron imagen completa, comparación del reparto a tamaño reducido y lectura sobre fondo claro (#fffdf8) y oscuro (#111e29), sin modificar el PNG original.

- Conserva tierra ocre y musgo; el cuerpo es ahora más horizontal, pesado y asimétrico.
- La mirada ámbar entrecerrada y la boca hundida sustituyen la gran esclerótica de la versión anterior.
- Los apoyos planos y la masa trasera lo separan de la marcha alta de Vainete y de las figuras erguidas.
- Contorno y gesto reconocibles en reducción y sobre ambos fondos; sin recorte visible del cuerpo.

## Comprobación técnica

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/terron/concept_v003.png
```

Resultado: **Pendiente el margen de producción**, código de salida 1. La imagen es RGBA y tiene fondo transparente, pero el comprobador detecta alfa residual hasta el borde. Se conserva como concepto, sin declararlo sprite preparado. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Fotogramas | 1, imagen estática |
| Límites con alfa no nulo | [0, 21, 1243, 1254] |
| Margen mínimo | 0 px; referencia para producción: 4 px |
| Peso | 1335435 bytes |
| SHA-256 | `5f0048b4fcde3bd9c69635fd43775dd422ec66ce1d982b3a4d0614b761b87b72` |

## Pendiente

Valorar esta revisión visual con el usuario, incorporar la referencia completa de «opción A», preparar celdas y pivote, producir animaciones e integrar los recursos. Las descripciones de gestos son propuestas de animación; no se han producido sus secuencias ni probado Godot, Android o Windows.

Estado: **concept_only**. La aprobación del concepto base no equivale a una selección de esta imagen nueva.
