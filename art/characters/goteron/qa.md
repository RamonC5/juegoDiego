# Revisión de Goterón

Fecha: **15 de octubre de 2026**. Alcance: imagen de concepto estática.

## Comprobación técnica

Comando ejecutado desde la raíz del proyecto:

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/goteron/concept_v003.png
```

Resultado: **Correcto**, código de salida 0. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Transparencia | Fondo con alfa 0 y personaje visible |
| Fotogramas | 1 imagen estática; cuadrícula 1 × 1 |
| Límites con alfa no nulo | [82, 142, 1232, 1188] |
| Margen mínimo | 22 px; mínimo exigido: 4 px |
| Peso | 674845 bytes |
| SHA-256 | `f0c6ef92f5096547b7cd458f5629ead63f63edfc3100121fc510330adc63dba3` |

Se generó una revisión mediante `image_gen` tras detectar alfa residual hasta el borde en la primera imagen. Las entradas de edición se conservan en `sources/`; el resultado real de la revisión figura en el informe técnico. No se ha retocado el PNG con scripts.

## Revisión visual

Se inspeccionó el personaje completo y su lectura reducida a aproximadamente 96 px sobre fondo claro (#fffdf8) y oscuro (#111e29). La vista de comprobación no modifica el PNG de autoría.

- Cuerpo de gel bajo y alargado, cola y base de deslizamiento completas.
- Frente y cola diferentes, con un ojo que marca la dirección; el lomo carece de punta o pinchos.
- Se conservan identidad, materiales y pose tras las correcciones.
- Bordes y silueta legibles sobre ambos fondos y en la vista reducida.

## Pendiente para producción

Aprobación visual del usuario y contraste con la descripción completa de «opción A». Preparar celdas, pivote y animaciones; revisar continuidad temporal y raíz estable. Importar y comprobar los recursos en Godot y probarlos después en Android y Windows.

Estado: **concept_only**. No se han probado animación, jugabilidad ni funcionamiento en dispositivos.
