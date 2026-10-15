# Revisión de Remiendo

Fecha: **15 de octubre de 2026**. Alcance: imagen de concepto estática.

## Comprobación técnica

Comando ejecutado desde la raíz del proyecto:

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/remiendo/concept_v003.png
```

Resultado: **Pendiente el margen de producción**, código de salida 1. El PNG es RGBA con fondo transparente y personaje completo, pero existen píxeles de alfa residual hasta el borde. Se entrega como concepto y no como sprite listo. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Transparencia | Fondo con alfa 0 y personaje visible |
| Fotogramas | 1 imagen estática; cuadrícula 1 × 1 |
| Límites con alfa no nulo | [0, 95, 1210, 1140] |
| Margen mínimo | 0 px; mínimo exigido: 4 px |
| Peso | 1108744 bytes |
| SHA-256 | `7d6c15e66e79573f384befd85e667ef195a63093577a0773f8d84105279a6707` |

Se generó una revisión mediante `image_gen` tras detectar alfa residual hasta el borde en la primera imagen. Las entradas de edición se conservan en `sources/`; el resultado real de la revisión figura en el informe técnico. No se ha retocado el PNG con scripts.

## Revisión visual

Se inspeccionó el personaje completo y su lectura reducida a aproximadamente 96 px sobre fondo claro (#fffdf8) y oscuro (#111e29). La vista de comprobación no modifica el PNG de autoría.

- Cuerpo acolchado completo, costura superior plegada, parche lateral y dos pies diferenciados.
- Se conservan identidad, proporciones y materiales tras las revisiones.
- El ojo, la parte superior blanda y el parche se reconocen sobre ambos fondos y en reducción.
- No hay recorte visible del personaje. El control técnico sigue detectando alfa residual hasta el borde: queda registrado para la preparación posterior de sprites.

## Pendiente para producción

Aprobación visual del usuario y contraste con la descripción completa de «opción A». Preparar celdas, pivote y animaciones; revisar continuidad temporal y raíz estable. Importar y comprobar los recursos en Godot y probarlos después en Android y Windows.

Estado: **concept_only**. No se han probado animación, jugabilidad ni funcionamiento en dispositivos.
