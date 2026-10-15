# Revisión de Plumín

Fecha: **15 de octubre de 2026**. Alcance: imagen de concepto estática.

## Comprobación técnica

Comando ejecutado desde la raíz del proyecto:

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/plumin/concept_v002.png
```

Resultado: **Correcto**, código de salida 0. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Transparencia | Fondo con alfa 0 y personaje visible |
| Fotogramas | 1 imagen estática; cuadrícula 1 × 1 |
| Límites con alfa no nulo | [17, 161, 1235, 1198] |
| Margen mínimo | 17 px; mínimo exigido: 4 px |
| Peso | 954292 bytes |
| SHA-256 | `dccf8c9d7015fcb1666ed5197980bfb87c864444a9676276712e83e164aa4131` |

Se generó una revisión mediante `image_gen` tras detectar alfa residual hasta el borde en la primera imagen. Las entradas de edición se conservan en `sources/`; el resultado real de la revisión figura en el informe técnico. No se ha retocado el PNG con scripts.

## Revisión visual

Se inspeccionó el personaje completo y su lectura reducida a aproximadamente 96 px sobre fondo claro (#fffdf8) y oscuro (#111e29). La vista de comprobación no modifica el PNG de autoría.

- Cuerpo de pera, pico, ala plegada y dos pies completos de perfil hacia la derecha.
- Cabeza suave y sin cresta; la dirección sigue siendo clara a tamaño reducido.
- El pecho claro y la silueta permanecen legibles sobre fondos claros y oscuros.
- La corrección conserva la identidad; no se observan recortes ni elementos extra.

## Pendiente para producción

Aprobación visual del usuario y contraste con la descripción completa de «opción A». Preparar celdas, pivote y animaciones; revisar continuidad temporal y raíz estable. Importar y comprobar los recursos en Godot y probarlos después en Android y Windows.

Estado: **concept_only**. No se han probado animación, jugabilidad ni funcionamiento en dispositivos.
