# Revisión de Vainete

Fecha: **15 de octubre de 2026**. Alcance: imagen de concepto estática.

## Comprobación técnica

Comando ejecutado desde la raíz del proyecto:

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/vainete/concept_v001.png
```

Resultado: **Correcto**, código de salida 0. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Transparencia | Fondo con alfa 0 y personaje visible |
| Fotogramas | 1 imagen estática; cuadrícula 1 × 1 |
| Límites con alfa no nulo | [31, 17, 1202, 1230] |
| Margen mínimo | 17 px; mínimo exigido: 4 px |
| Peso | 1032011 bytes |
| SHA-256 | `c2f53203a1876ffe73993a6118b5e1b53fc45c150eb26d4c117f54ac2f3d6ecd` |

La imagen seleccionada es la primera generación; se conserva sin retoques mediante scripts.

## Revisión visual

Se inspeccionó el personaje completo y su lectura reducida a aproximadamente 96 px sobre fondo claro (#fffdf8) y oscuro (#111e29). La vista de comprobación no modifica el PNG de autoría.

- Se distinguen tres volúmenes vegetales unidos y tres apoyos del lado visible.
- Vista lateral hacia la derecha, personaje completo y dorso redondeado sin elementos punzantes.
- Las divisiones amplias y los apoyos conservan su lectura en reducción.
- No se observan fondo dibujado, suelo, texto ni recortes visibles.

## Pendiente para producción

Aprobación visual del usuario y contraste con la descripción completa de «opción A». Preparar celdas, pivote y animaciones; revisar continuidad temporal y raíz estable. Importar y comprobar los recursos en Godot y probarlos después en Android y Windows.

Estado: **concept_only**. No se han probado animación, jugabilidad ni funcionamiento en dispositivos.
