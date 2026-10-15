# Vainete · personalidad e identidad visual

**ID:** `vainete` · **Revisión visual:** 002 · **Rol:** enemigo normal eliminable por pisotón.

**Concepto base:** valorado positivamente por el usuario. **Nueva versión visual:** propuesta, pendiente de su valoración. Fecha: 15 de octubre de 2026.

![Vainete disciplinado: vaina verde larga de tres segmentos, raíces finas, bigote vegetal caído y una pata delantera levantada.](concept_v002.png)

## Personalidad

**Disciplinado, orgulloso, meticuloso.** Marca el paso aunque nadie lo esté siguiendo.

| Rasgo propio | Diseño de esta revisión |
| --- | --- |
| Silueta y proporciones | Vaina muy alargada de tres volúmenes suaves y seis raíces finas. |
| Rostro | Ojo verde pequeño y almendrado, y dos fibras vegetales caídas como bigote. |
| Postura clave | Cuerpo horizontal recto; una raíz delantera levantada en un paso medido. |
| Gesto característico propuesto | Se detiene, endereza el cuerpo y reanuda la marcha con un paso exacto. |
| Concepto y materiales conservados | vaina verde de tres volúmenes, piel vegetal, apoyos de raíz |

La diferencia de identidad se apoya en forma, cara y postura; el acabado y la iluminación siguen perteneciendo al mismo juego. La [versión anterior](concept_v001.png) se conserva.

## Comportamiento propuesto

**Desplazamiento:** Marcha a ritmo regular, hace una pausa firme al final del recorrido y gira con precisión.

**Pisotón:** Los tres volúmenes se comprimen juntos y las raíces se repliegan.

Estos gestos y patrones aún no son animaciones ni comportamiento ejecutable. Velocidad, tiempos, contacto lateral y rebote del jugador se ajustarán al implementar las mecánicas. Los sensores y colisiones serán independientes de la imagen.

## Requisitos y estado técnico

Se mantienen 2D, Android y Windows, ocho mundos, niveles rejugables y enemigos normales eliminables por pisotón. El personaje no tiene un mundo asignado; su identificador se conserva para reutilizarlo y mantener la rejugabilidad. La descripción completa de «opción A» sigue pendiente de incorporarse.

[concept_v002.png](concept_v002.png) es un PNG RGBA de **1254 × 1254 px** con fondo transparente y margen mínimo medido de **0 px**. Se entrega como concepto estático, con vista lateral orientada a la derecha.

La revisión técnica conserva un aviso de alfa residual hasta el borde; su limpieza y el margen se resolverán al preparar los sprites.

Se propone producir después `patrol`, `stomped` y `defeated` en celdas de 256 × 256, con raíz [128, 224] por verificar. La preparación de sprites, las animaciones, `SpriteFrames`, la escena de enemigo y la integración jugable quedan pendientes.

## Archivos

- [Encargo y decisiones](brief.yaml).
- [Prompts exactos y versiones](prompts.md).
- [Metadatos y estado de producción](character.json).
- [Revisión visual](qa.md) e [informe técnico](qa-technical.json).

Volver al [catálogo y comparación del reparto](../../../docs/PERSONAJES.md).
