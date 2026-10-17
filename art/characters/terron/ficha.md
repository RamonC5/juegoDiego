# Terrón · personalidad e identidad visual

**ID:** `terron` · **Revisión visual:** 003 · **Rol:** enemigo normal eliminable por pisotón.

**Concepto base:** valorado positivamente por el usuario. **Nueva versión visual:** propuesta, pendiente de su valoración. Fecha: 15 de octubre de 2026.

![Terrón dormilón: bloque bajo y asimétrico de tierra y musgo, ojo pequeño entrecerrado y dos apoyos planos.](concept_v003.png)

## Personalidad

**Dormilón, pesado, testarudo.** El que tarda en arrancar y después sigue a lo suyo.

| Rasgo propio | Diseño de esta revisión |
| --- | --- |
| Silueta y proporciones | Cuerpo muy bajo y horizontal, con mayor masa en el lomo trasero y frente hundida. |
| Rostro | Ojo ámbar entrecerrado, casi sin blanco, y boca encogida bajo una mejilla pesada. |
| Postura clave | Peso hundido entre dos apoyos de raíz ensanchados y mentón bajo. |
| Gesto característico propuesto | Parpadeo lento, pausa larga y arranque pesado con un pequeño cabeceo. |
| Concepto y materiales conservados | cuerpo de tierra ocre, lomo de musgo, dos apoyos de raíz |

La diferencia de identidad se apoya en forma, cara y postura; el acabado y la iluminación siguen perteneciendo al mismo juego. La [versión anterior](concept_v002.png) se conserva.

## Comportamiento propuesto

**Desplazamiento:** Avanza despacio, se detiene como si se quedara dormido y reanuda con dos pasos pesados.

**Pisotón:** El lomo baja y el cuerpo se asienta de golpe; el musgo se sacude sin pinchos ni destellos.

Estos gestos y patrones aún no son animaciones ni comportamiento ejecutable. Velocidad, tiempos, contacto lateral y rebote del jugador se ajustarán al implementar las mecánicas. Los sensores y colisiones serán independientes de la imagen.

## Requisitos y estado técnico

Se mantienen 2D, Android y Windows, ocho mundos, niveles rejugables y enemigos normales eliminables por pisotón. El personaje no tiene un mundo asignado; su identificador se conserva para reutilizarlo y mantener la rejugabilidad. La descripción completa de «opción A» sigue pendiente de incorporarse.

[concept_v003.png](concept_v003.png) es un PNG RGBA de **1254 × 1254 px** con fondo transparente y margen mínimo medido de **0 px**. Se entrega como concepto estático, con vista lateral orientada a la derecha.

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

El raster existente tiene animación por malla 2D con perfiles propios de anatomía. Alterna sus dos apoyos de raíz; no se añaden brazos a su diseño. No hay hojas de fotogramas nuevas.

La animación se reproduce en el bosque y respeta persecución, pausa, caída y derrota. Los sensores permanecen independientes del dibujo. [Contrato, visor y verificación](../../../docs/ANIMACION_ENEMIGOS.md).

### Revisión del movimiento · 0.7.2

El rig conserva el PNG y la anatomía. La marcha sigue la distancia real, los apoyos alternan suelo y arco, las muñecas acompañan al brazo con desplazamientos menores y las rotaciones respetan la proporción del recorte en píxeles. Reposo, frenado, persecución y caída se mezclan sin reiniciar el ciclo; el aleteo conserva su frecuencia común. La suite `test_enemy_motion.gd` supera 198 comprobaciones. Integración jugable solo para Terrón y Moflete; los otros cinco mantienen su alcance de visor. Pruebas físicas Android/Windows pendientes.
