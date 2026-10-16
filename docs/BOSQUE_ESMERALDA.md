# Bosque Esmeralda · 1-1

**El despertar del bosque** es el primer nivel jugable de Salto Heroes, para Android y Windows. Se abre al iniciar el juego; el entrenamiento anterior sigue accesible desde Pausa.

![Bosque Esmeralda: árboles con musgo, luz cálida y profundidad de fondo](../game/assets/textures/environments/bosque_esmeralda/forest_backdrop_v001.png)

## Recorrido

| Tramo en píxeles lógicos | Experiencia |
| --- | --- |
| 0–1700 | Espacio seguro inicial, primeras hojas, plataformas altas opcionales, barril y primer Terrón |
| 1820–3470 | Primera brecha, Moflete, plataformas de exploración y práctica de lanzamientos |
| 3590–5100 | Farol de control en x=4160 y desvío alto con cristal |
| 5220–6900 | Piña lanzable, dos patrullas y último cristal |
| 7020–8200 | Última brecha, patrulla final y arco de salida en x=7900 |

Las cuatro brechas miden 120 px y se han cruzado caminando con salto completo en la prueba física. Las plataformas opcionales dejan atravesarlas desde abajo y sostienen al aterrizar desde arriba. Los tres cristales están en plataformas altas; no son necesarios para completar el nivel. El farol permite reintentar con tres puntos de energía y conserva lo recogido durante ese intento. Reiniciar el nivel empieza una partida nueva.

Se mantienen ocho identificadores de mundo. Esta entrega incorpora solo `world_01_level_01`; no crea los otros siete mundos ni un jefe del bosque.

## Controles

- Arrastra horizontalmente desde cualquier punto de la mitad de movimiento; un recorrido largo permite correr. Suelta para parar.
- En la otra mitad, desliza hacia arriba para saltar; mantén para ganar altura. Un toque corto recoge o lanza.
- Puedes mover, saltar y actuar con varios dedos simultáneos. En Pausa puedes intercambiar las mitades, ajustar recorrido o activar salto completo.
- Teclado: A/D o flechas, Espacio, E y Escape; también admite mando y reasignación.

La interfaz respeta la zona segura, ofrece foco visible y botones de pausa de al menos 54 px lógicos. Energía y coleccionables se identifican por texto y forma, además de color. No hay sacudidas de cámara ni daño con parpadeos. No se ha validado un lector de pantalla.

## Arte e integración

Sprites y fondos raster HD, vista lateral, materiales con textura y sombreado suave, coherentes con Diego y los conceptos existentes. El acabado mantiene las restricciones documentadas de la opción A; no se añade una especificación canónica que no conste en el proyecto.

Se han creado fondo, terreno y un atlas de árbol, helechos, arco y farol. Los PNG originales se conservan en el proyecto; Godot realiza los recortes. Terrón y Moflete reutilizan su arte y usan animación por transformación para caminar, recibir un pisotón y desaparecer. No se presentan como hojas de fotogramas nuevas. Las hojas doradas y cristales son formas 2D con facetas, de lectura sencilla en móvil.

Prompts exactos: [material de producción](../art/levels/bosque_esmeralda/prompts.md). Datos editables: [`level_01.tres`](../game/data/worlds/world_01/level_01.tres).

## Progreso y verificación

`user://progress.json` guarda el estado completado, número de finalizaciones, máximos de hojas y cristales y mejor tiempo por identificador. Se escribe primero un temporal; rejugar conserva los mejores resultados y el acceso al nivel. Los ajustes de control se guardan por separado.

La CI exige 148 comprobaciones: 55 del protagonista y controles, 63 de objetos y 30 del nivel. Estas últimas cubren contacto lateral, pisotón con rebote, impacto arrojadizo, recogida única, las cuatro brechas, plataforma atravesable, checkpoint, caída y reintento, pausa del reloj, recorrido completo, meta única y guardado rejugable. Captura el juego con Compatibility en 1280×720, tablet 1024×768 y panorámico 1600×720; las imágenes se publican como artefacto de Actions.

El objetivo es 60 FPS. Las pruebas automatizadas y las capturas no son una medición de rendimiento en un teléfono físico. Queda pendiente la prueba física de instalación, tacto y rendimiento en el móvil del usuario.
