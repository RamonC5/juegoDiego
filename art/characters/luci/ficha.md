# Luci · Ayudante del Bosque Esmeralda

Luci es una luciérnaga opcional que duerme en una planta del primer claro y acompaña a Diego cuando reúne tres fragmentos. El nombre y el diseño concreto son la propuesta integrada a partir del plan autorizado de un ayudante del bosque.

![Luci, luciérnaga de cuerpo verde musgo, abdomen ámbar luminoso y alas translúcidas de hoja en cuatro poses de aleteo.](concept_v001.png)

Cuerpo pequeño y suspendido, seis patas de insecto recogidas, antenas curvas y alas de hoja. Textura raster 2D HD, sombreado suave, cámara lateral e iluminación coherente con el bosque. No es un enemigo y no recibe daño ni introduce colisiones.

El PNG de 1254 × 1254 contiene cuatro celdas de 627 × 627. Las alas cambian de apertura y las puntas muestran retraso entre las poses. El ciclo de 12 fotogramas/s produce tres aleteos por segundo y se detiene en pausa. Los pivotes del ojo mantienen el cuerpo aproximadamente estable; el acompañamiento y el pequeño movimiento de celebración se calculan por separado.

Recurso: `game/assets/textures/characters/luci/flutter_v001.png`. Código: `ForestFirefly`. Arte generado con la herramienta integrada; [prompt exacto](prompts.md), [metadatos](character.json) y [revisión técnica](qa.md). El PNG fuente presenta alfa residual muy bajo en los márgenes, eliminado por el recorte suave del shader existente; no se ha retocado con Python.

La integración y pruebas del guardado se describen en [Recompensas](../../../docs/RECOMPENSAS.md). La revisión en Android y Windows físicos sigue pendiente.
