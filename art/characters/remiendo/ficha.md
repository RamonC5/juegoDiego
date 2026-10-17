# Remiendo · personalidad e identidad visual

**ID:** `remiendo` · **Revisión visual:** 004 · **Rol:** enemigo normal eliminable por pisotón.

**Concepto base:** valorado positivamente por el usuario. **Nueva versión visual:** propuesta, pendiente de su valoración. Fecha: 15 de octubre de 2026.

![Remiendo tímido: muñeco de lona crema alto y ladeado, parche azul verdoso, ojo de botón, brazos blandos y pies desiguales.](concept_v004.png)

## Personalidad

**Tímido, torpe, desgarbado.** Intenta ocupar poco espacio, pero siempre deja un pie por medio.

| Rasgo propio | Diseño de esta revisión |
| --- | --- |
| Silueta y proporciones | Muñeco de tela alto y ladeado, un hombro más bajo, brazos blandos y pies desiguales. |
| Rostro | Botón oscuro pequeño como ojo visible y boca bordada corta y encogida. |
| Postura clave | Hombros caídos; una mano de tela sujeta el otro antebrazo y un pie grande apunta hacia dentro. |
| Gesto característico propuesto | Mira de reojo, se recoge un brazo y da un paso vacilante con el pie demasiado grande. |
| Concepto y materiales conservados | lona crema acolchada, parche azul verdoso, costuras visibles |

La diferencia de identidad se apoya en forma, cara y postura; el acabado y la iluminación siguen perteneciendo al mismo juego. La [versión anterior](concept_v003.png) se conserva.

## Comportamiento propuesto

**Desplazamiento:** Alterna pasos desiguales y una pequeña pausa para recuperar el equilibrio.

**Pisotón:** La tela pierde volumen, los brazos caen y los dos pies quedan abiertos, sin violencia gráfica.

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


## Movimiento articulado · 17 de octubre de 2026

El raster existente tiene animación por malla 2D con perfiles propios de anatomía. Balancea ambos brazos y manos con retraso en las muñecas y alterna los pies. No hay hojas de fotogramas nuevas.

La animación se revisa en `enemy_gallery.tscn`; su IA, combate y colocación en niveles siguen pendientes. Los sensores permanecen independientes del dibujo. [Contrato, visor y verificación](../../../docs/ANIMACION_ENEMIGOS.md).
