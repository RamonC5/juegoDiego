# Revisión de personalidad de Goterón

Fecha: **15 de octubre de 2026**. Alcance: concepto 2D estático, versión 004.

## Revisión solicitada y referencia

El usuario valora el concepto de criatura y pide más personalidad y menor parecido entre personajes. Se contrasta esta revisión con [concept_v003.png](concept_v003.png) y con las otras cinco nuevas imágenes del catálogo.

## Revisión visual realizada

Se inspeccionaron imagen completa, comparación del reparto a tamaño reducido y lectura sobre fondo claro (#fffdf8) y oscuro (#111e29), sin modificar el PNG original.

- Conserva gel turquesa, base deslizante y cola; la parte delantera forma una curva blanda y vencida.
- Dos marcas oculares oscuras desiguales y sonrisa pequeña aportan una expresión bonachona propia.
- El hueco bajo el cuello y la base continua producen un contorno diferente al resto del reparto.
- Personaje completo y lectura clara a tamaño reducido sobre ambos fondos.

## Comprobación técnica

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/goteron/concept_v004.png
```

Resultado: **Correcto**, código de salida 0. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Fotogramas | 1, imagen estática |
| Límites con alfa no nulo | [41, 101, 1236, 1236] |
| Margen mínimo | 18 px; referencia para producción: 4 px |
| Peso | 694154 bytes |
| SHA-256 | `256541db5ca1df2e3a9bc1b6ad51cf12bd3c073e347ec2d523b0bf35a1a99199` |

## Pendiente

Valorar esta revisión visual con el usuario, incorporar la referencia completa de «opción A», preparar celdas y pivote, producir animaciones e integrar los recursos. Las descripciones de gestos son propuestas de animación; no se han producido sus secuencias ni probado Godot, Android o Windows.

Estado: **concept_only**. La aprobación del concepto base no equivale a una selección de esta imagen nueva.
