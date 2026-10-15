# Moflete · personalidad e identidad visual

**ID:** `moflete` · **Revisión visual:** 004 · **Rol:** enemigo normal eliminable por pisotón.

**Concepto base:** valorado positivamente por el usuario. **Nueva versión visual:** propuesta, pendiente de su valoración. Fecha: 15 de octubre de 2026.

![Moflete curioso: roedor cobrizo de cuerpo erguido y estrecho, grandes mejillas crema, ojo pequeño y patas en puntillas.](concept_v004.png)

## Personalidad

**Curioso, glotón, inquieto.** Primero olfatea; después descubre que iba demasiado deprisa.

| Rasgo propio | Diseño de esta revisión |
| --- | --- |
| Silueta y proporciones | Roedor erguido de tronco estrecho, mejilla desproporcionada y cola curvada. |
| Rostro | Ojo oscuro redondo sin blanco, nariz pequeña y boca abierta de sorpresa. |
| Postura clave | Dos patas traseras alargadas en puntillas y manos pequeñas cerca de las mejillas. |
| Gesto característico propuesto | Olfatea con rapidez, hincha una mejilla y junta las manos antes de dar un paso. |
| Concepto y materiales conservados | pelaje cobrizo, mejillas y vientre crema, cola de roedor |

La diferencia de identidad se apoya en forma, cara y postura; el acabado y la iluminación siguen perteneciendo al mismo juego. La [versión anterior](concept_v003.png) se conserva.

## Comportamiento propuesto

**Desplazamiento:** Da varios pasos rápidos, frena para olfatear y gira con una pequeña vacilación.

**Pisotón:** Las mejillas se desinflan, el cuerpo se encoge y las orejas laterales bajan.

Estos gestos y patrones aún no son animaciones ni comportamiento ejecutable. Velocidad, tiempos, contacto lateral y rebote del jugador se ajustarán al implementar las mecánicas. Los sensores y colisiones serán independientes de la imagen.

## Requisitos y estado técnico

Se mantienen 2D, Android y Windows, ocho mundos, niveles rejugables y enemigos normales eliminables por pisotón. El personaje no tiene un mundo asignado; su identificador se conserva para reutilizarlo y mantener la rejugabilidad. La descripción completa de «opción A» sigue pendiente de incorporarse.

[concept_v004.png](concept_v004.png) es un PNG RGBA de **1254 × 1254 px** con fondo transparente y margen mínimo medido de **0 px**. Se entrega como concepto estático, con vista lateral orientada a la derecha.

La revisión técnica conserva un aviso de alfa residual hasta el borde; su limpieza y el margen se resolverán al preparar los sprites.

Se propone producir después `patrol`, `stomped` y `defeated` en celdas de 256 × 256, con raíz [128, 224] por verificar. La preparación de sprites, las animaciones, `SpriteFrames`, la escena de enemigo y la integración jugable quedan pendientes.

## Archivos

- [Encargo y decisiones](brief.yaml).
- [Prompts exactos y versiones](prompts.md).
- [Metadatos y estado de producción](character.json).
- [Revisión visual](qa.md) e [informe técnico](qa-technical.json).

Volver al [catálogo y comparación del reparto](../../../docs/PERSONAJES.md).
