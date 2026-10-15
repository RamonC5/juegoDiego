# Revisión de Moflete

Fecha: **15 de octubre de 2026**. Alcance: imagen de concepto estática.

## Comprobación técnica

Comando ejecutado desde la raíz del proyecto:

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/moflete/concept_v003.png
```

Resultado: **Correcto**, código de salida 0. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Transparencia | Fondo con alfa 0 y personaje visible |
| Fotogramas | 1 imagen estática; cuadrícula 1 × 1 |
| Límites con alfa no nulo | [75, 33, 1220, 1212] |
| Margen mínimo | 33 px; mínimo exigido: 4 px |
| Peso | 1140535 bytes |
| SHA-256 | `1526016ccf11ade0b0434fbdb316d04da298925d439a33c83f82a706beec4957` |

Se generó una revisión mediante `image_gen` tras detectar alfa residual hasta el borde en la primera imagen. Las entradas de edición se conservan en `sources/`; el resultado real de la revisión figura en el informe técnico. No se ha retocado el PNG con scripts.

## Revisión visual

Se inspeccionó el personaje completo y su lectura reducida a aproximadamente 96 px sobre fondo claro (#fffdf8) y oscuro (#111e29). La vista de comprobación no modifica el PNG de autoría.

- Cuerpo cobrizo completo de perfil hacia la derecha, con oreja lateral, hocico y apoyos reconocibles.
- Lomo redondeado y despejado; la silueta se distingue de Terrón.
- El ojo, la dirección y los apoyos se leen en reducción sobre fondo claro y oscuro.
- No se observan recortes, fondo dibujado, texto ni elementos añadidos en la corrección.

## Pendiente para producción

Aprobación visual del usuario y contraste con la descripción completa de «opción A». Preparar celdas, pivote y animaciones; revisar continuidad temporal y raíz estable. Importar y comprobar los recursos en Godot y probarlos después en Android y Windows.

Estado: **concept_only**. No se han probado animación, jugabilidad ni funcionamiento en dispositivos.
