# Revisión de personalidad de Remiendo

Fecha: **15 de octubre de 2026**. Alcance: concepto 2D estático, versión 004.

## Revisión solicitada y referencia

El usuario valora el concepto de criatura y pide más personalidad y menor parecido entre personajes. Se contrasta esta revisión con [concept_v003.png](concept_v003.png) y con las otras cinco nuevas imágenes del catálogo.

## Revisión visual realizada

Se inspeccionaron imagen completa, comparación del reparto a tamaño reducido y lectura sobre fondo claro (#fffdf8) y oscuro (#111e29), sin modificar el PNG original.

- Conserva lona crema y parche azul verdoso; la figura se vuelve alta, ladeada y de pies desiguales.
- Ojo de botón, boca bordada pequeña y mano que recoge el otro brazo comunican timidez.
- Brazos largos, hombros caídos y pie grande lo distinguen del paso abierto de Plumín y del gesto alerta de Moflete.
- El botón, el parche y la postura siguen siendo reconocibles en reducción; cuerpo y extremidades completos sobre ambos fondos.

## Comprobación técnica

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/remiendo/concept_v004.png
```

Resultado: **Pendiente el margen de producción**, código de salida 1. La imagen es RGBA y tiene fondo transparente, pero el comprobador detecta alfa residual hasta el borde. Se conserva como concepto, sin declararlo sprite preparado. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Fotogramas | 1, imagen estática |
| Límites con alfa no nulo | [0, 17, 1253, 1254] |
| Margen mínimo | 0 px; referencia para producción: 4 px |
| Peso | 1123516 bytes |
| SHA-256 | `c1378b1e3eb06c27372b05e2984b97af325e1a8ec306542c889c8bfce3e4c990` |

## Pendiente

Valorar esta revisión visual con el usuario, incorporar la referencia completa de «opción A», preparar celdas y pivote, producir animaciones e integrar los recursos. Las descripciones de gestos son propuestas de animación; no se han producido sus secuencias ni probado Godot, Android o Windows.

Estado: **concept_only**. La aprobación del concepto base no equivale a una selección de esta imagen nueva.
