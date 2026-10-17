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

## Integración en Bosque Esmeralda 1-1

El primer nivel reutiliza este concepto como sprite raster lateral. `ForestEnemy` implementa patrulla, contacto lateral, pisotón con rebote y recepción de objetos lanzados. La animación usa balanceo y compresión del sprite existente; no se han generado hojas de carrera nuevas. El PNG final se importa con un límite de 512 px y mantiene el recorte normalizado y la colisión separados. La revisión de juego cubre combate y recorrido; la prueba en un móvil físico queda pendiente.


## Movimiento articulado · 17 de octubre de 2026

El raster existente tiene animación por malla 2D con perfiles propios de anatomía. Mueve los dos brazos y sus manos con flexión de muñeca desfasada, además de alternar los pies. No hay hojas de fotogramas nuevas.

La animación se reproduce en el bosque y respeta persecución, pausa, caída y derrota. Los sensores permanecen independientes del dibujo. [Contrato, visor y verificación](../../../docs/ANIMACION_ENEMIGOS.md).

### Revisión del movimiento · 0.7.2

El rig conserva el PNG y la anatomía. La marcha sigue la distancia real, los apoyos alternan suelo y arco, las muñecas acompañan al brazo con desplazamientos menores y las rotaciones respetan la proporción del recorte en píxeles. Reposo, frenado, persecución y caída se mezclan sin reiniciar el ciclo; el aleteo conserva su frecuencia común. La suite `test_enemy_motion.gd` supera 198 comprobaciones. Integración jugable solo para Terrón y Moflete; los otros cinco mantienen su alcance de visor. Pruebas físicas Android/Windows pendientes.
