# Moflete · enemigo normal de Salto Heroes

**Identificador:** `moflete` · **Versión visual:** 003 · **Estado:** propuesta de concepto · **Fecha:** 15 de octubre de 2026.

![Moflete de perfil hacia la derecha: cuerpo bajo de pelaje cobrizo, mejilla crema, orejas laterales redondeadas y pies cortos.](concept_v003.png)

## Identidad visual propuesta

| Rasgo | Diseño |
| --- | --- |
| Concepto | Criatura de pelaje compacto |
| Silueta | Óvalo corto y abombado, hocico redondeado y dos orejas pequeñas pegadas a los lados. |
| Materiales | pelaje corto y denso, almohadillas mates |
| Paleta | cobre rojizo, crema, marrón oscuro |
| Vista | Lateral hacia la derecha; personaje completo |
| Luz | Suave desde arriba a la izquierda |
| Acabado | Raster 2D HD, texturas legibles y sombreado suave incorporado |
| Referencia de acabado | [Terrón](../terron/ficha.md), conservando una identidad diferente |

Nombre, especie, materiales, aspecto y patrón de movimiento son propuestas originales.

## Función y comportamiento propuestos

Enemigo normal eliminable mediante un pisotón válido, de acuerdo con la regla confirmada del proyecto.

**Movimiento:** Patrulla con pasos cortos y pausas de olfateo.

**Reacción al pisotón:** El cuerpo se comprime y el hocico baja al recibir el pisotón.

Los valores de velocidad, recorrido, contacto lateral, rebote del jugador y tiempos de derrota se decidirán durante la implementación. La detección del pisotón y las colisiones serán independientes del dibujo.

## Lectura y requisitos

- Lomo redondeado y despejado.
- Hocico que indica la dirección.
- Orejas plegadas fuera de la zona superior.

La forma y la postura complementan al color para reconocer la zona pisable y la dirección. Se ha revisado su lectura estática a tamaño reducido y sobre fondos claros y oscuros.

La entrega usa una imagen 2D compartible entre Android y Windows. No se asignan mundos ni temáticas: el ID estable podrá reutilizarse al definir los ocho mundos y sus niveles rejugables. La especificación completa de «opción A» sigue pendiente de incorporarse; este concepto conserva los requisitos visuales conocidos sin redefinir esa elección.

## Archivo entregado y producción pendiente

[concept_v003.png](concept_v003.png) es un **PNG RGBA de 1254 × 1254 px**, con transparencia real y margen mínimo medido de **33 px**. Es una imagen de concepto, no una hoja de animación.


| Acción futura | Propuesta | Estado |
| --- | --- | --- |
| `patrol` | 6 fotogramas, 10 FPS, bucle | Pendiente |
| `stomped` | 3 fotogramas, 12 FPS, sin bucle | Pendiente |
| `defeated` | 1 pose final, sin bucle | Pendiente |

Se propone celda de 256 × 256 y raíz [128, 224], pendientes de verificar con las poses reales. La animación, los recursos `SpriteFrames`, la escena y el comportamiento en Godot quedan pendientes.

## Archivos del personaje

- [Encargo y decisiones](brief.yaml).
- [Prompts exactos y referencias](prompts.md).
- [Metadatos y estado de producción](character.json).
- [Informe técnico](qa-technical.json) y [revisión visual](qa.md).

Volver al [catálogo de personajes](../../../docs/PERSONAJES.md).
