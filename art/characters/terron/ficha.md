# Terrón · primer enemigo normal de Salto Heroes

**Identificador:** `terron` · **Versión visual:** 002 · **Estado:** propuesta de concepto · **Fecha:** 15 de octubre de 2026.

![Terrón de perfil hacia la derecha, con cuerpo ocre de tierra, lomo de musgo verde, un ojo claro y dos pies de raíz.](concept_v002.png)

## Función en el juego

Primer diseño de enemigo normal eliminable saltando encima, conforme a la regla confirmada del proyecto. La propuesta de comportamiento es una patrulla terrestre sencilla, adecuada para presentar el pisotón. Al recibir un pisotón válido, se prevé una compresión visible del cuerpo y la derrota.

El contacto lateral, la velocidad, el rebote del jugador, las colisiones y el tiempo de desaparición se decidirán al implementar la mecánica. Los sensores de daño y pisotón serán independientes del dibujo.

## Identidad visual propuesta

| Rasgo | Diseño |
| --- | --- |
| Silueta | Baja, ancha y redondeada, con la cara orientada hacia delante |
| Cuerpo | Tierra ocre con grano fino y grietas anchas de bordes suaves |
| Parte superior | Cojín continuo de musgo blando, despejado de pinchos y objetos |
| Rostro | Un ojo claro visible de perfil, pupila oscura y expresión decidida |
| Apoyos | Dos pies cortos de raíz, reconocibles como formas separadas |
| Accesorios | Ninguno |
| Vista | Lateral hacia la derecha; personaje completo |
| Luz | Suave desde arriba a la izquierda |
| Acabado | Imagen raster 2D HD con textura y sombreado suave incorporados |

La zona pisable se comunica mediante su forma amplia y blanda, además del color. El ojo y los pies ayudan a reconocer dirección y postura a tamaño pequeño. El concepto mantiene una identidad propia sin reutilizar personajes ni imágenes de otros juegos.

## Relación con los requisitos

- **2D:** la entrega es un PNG raster; no requiere modelos ni escenas 3D.
- **Android y Windows:** la identidad visual se comparte; la lectura reducida se ha revisado en una vista estática, sin prueba todavía en dispositivos.
- **Ocho mundos y rejugabilidad:** no se asigna una temática o mundo nuevo. El ID `terron` podrá reutilizarse al definir niveles.
- **Pisotón:** lomo ancho sin elementos punzantes; se prevé una reacción de compresión para comunicar la derrota.
- **Dirección artística:** texturas legibles y sombreado suave, evitando aspecto de boceto o cómic. El detalle de «opción A» no está disponible; la propuesta deberá contrastarse con esa referencia cuando se incorpore.

## Imagen entregada y producción pendiente

El archivo [`concept_v002.png`](concept_v002.png) tiene **1254 × 1254 px**, formato **PNG RGBA**, transparencia real y un margen mínimo medido de **16 px**. Es una referencia visual, no una hoja de animación ni un sprite de producción en celdas de 256 × 256.

| Acción futura | Propuesta de producción | Estado |
| --- | --- | --- |
| `patrol` | 6 fotogramas, 10 FPS, bucle | Pendiente |
| `stomped` | 3 fotogramas, 12 FPS, sin bucle; compresión legible | Pendiente |
| `defeated` | 1 pose final, sin bucle | Pendiente |

Para producir sprites se propone celda de 256 × 256 y raíz [128, 224], pendientes de verificar con las poses reales. Todavía no existen `SpriteFrames`, escena, colisiones ni código de combate de Terrón.

## Archivos del personaje

- [Encargo y decisiones propuestas](brief.yaml).
- [Prompts exactos de generación y corrección](prompts.md).
- [Metadatos del personaje](character.json).
- [Informe técnico del PNG](qa-technical.json) y [revisión visual](qa.md).
- [Primera generación usada como referencia de corrección](sources/concept_v001.png).

Volver al [catálogo de personajes](../../../docs/PERSONAJES.md).

