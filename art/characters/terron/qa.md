# Revisión de Terrón

Fecha: **15 de octubre de 2026**. Alcance: imagen de concepto estática.

## Comprobación técnica

Comando ejecutado desde la raíz del proyecto:

```sh
python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py art/characters/terron/concept_v002.png
```

Resultado: **correcto**, código de salida 0. Informe completo en [qa-technical.json](qa-technical.json).

| Control | Resultado real |
| --- | --- |
| Dimensiones | 1254 × 1254 px |
| Formato | PNG RGBA |
| Rango alfa | 0–255; hay fondo completamente transparente |
| Fotogramas | 1 imagen estática, cuadrícula 1 × 1 |
| Límites con alfa no nulo | [97, 33, 1238, 1222], coordenadas del PNG |
| Margen mínimo de cualquier píxel con alfa | 16 px; requisito del comprobador: 4 px |
| Peso | 1 273 969 bytes |
| SHA-256 | `a430fac5ff12625a6d6a4e4bc0348f8cfdeb179105da22abcd4c1c0427e253ee` |

El margen incluye píxeles de alfa muy bajo; no se ha limpiado ni editado el PNG mediante scripts. La primera generación tenía píxeles con alfa hasta el borde y fallaba el control de margen. Se corrigió mediante `image_gen` y se conserva únicamente como referencia histórica en [sources/concept_v001.png](sources/concept_v001.png).

## Revisión visual realizada

Se inspeccionó la imagen completa y una composición temporal de visualización sobre fondo claro (#fffdf8) y oscuro (#111e29), incluyendo una vista reducida de aproximadamente 96 px. El PNG de autoría se mantuvo sin modificaciones durante la visualización.

- Personaje completo y orientado a la derecha; se distinguen los dos apoyos.
- Silueta baja, ojo claro y parte superior de musgo reconocibles en reducción.
- Zona superior amplia y despejada, sin pinchos ni elementos que contradigan el pisotón.
- No se observan fondo dibujado, suelo, texto, marca de agua ni recortes visibles.
- Bordes legibles sobre las dos superficies revisadas.
- La identidad y la pose se conservan en la corrección.

## Pendiente para producción

Aprobación visual del usuario y contraste con la descripción completa de «opción A». Preparar celdas, pivote y animaciones; revisar continuidad temporal y raíz estable. Importar y comprobar los recursos en Godot, después probar tamaño real, rendimiento y lectura en Android y Windows.

Estado: **concept_only**. Esta comprobación no acredita animación, integración jugable ni compatibilidad probada en dispositivos.

