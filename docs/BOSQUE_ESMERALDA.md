# Bosque Esmeralda · 1-1

**El despertar del bosque** es el primer nivel jugable de Salto Heroes, para Android y Windows. Se abre al iniciar el juego; el entrenamiento anterior sigue accesible desde Pausa.

![Bosque Esmeralda: árboles con musgo, luz cálida y profundidad de fondo](../game/assets/textures/environments/bosque_esmeralda/forest_backdrop_v001.png)

## Recorrido

| Tramo en píxeles lógicos | Experiencia |
| --- | --- |
| 0–1700 | Espacio seguro inicial, primera llave de ramas en x=820, hojas, barril y primer Terrón |
| 1820–2850 | Moflete, plataforma opcional y farol de ensayo en x=2470; piña en x=2540 y diana en x=2780 |
| 2850–3270 | Pasarela de ensayo de 420 px, suelo inferior y escalones de retorno |
| 3270–3790 | Farol en x=3390, piña en x=3430 y diana principal en x=3710 |
| 3790–4270 | Puente de raíces de 480 px, abierto mediante lanzamiento |
| 4270–5100 | Llave 2 en x=4560, farol en x=4820, patrulla y ruta opcional al cristal alto |
| 5220–6900 | Vasija lanzable, dos patrullas, tercera llave en x=6600 y último cristal |
| 7020–8200 | Último hueco de salto, patrulla y puerta en x=7900, que exige tres llaves |

Las tres brechas normales miden 120 px; los dos pasos amplios requieren activar sus dianas. La [dinámica del puente de raíces](dinamicas/puente_diana.md) reutiliza la recogida y el lanzamiento: un toque coge una piña y otro la lanza. La diana acepta cualquier arrojadizo válido. El ensayo ofrece suelo inferior y apoyos de retorno, probados con saltos reales. Las piñas perdidas vuelven a sus puestos.

Volver al farol conserva llaves, hojas, cristales y puentes resueltos del intento. Un despliegue interrumpido se restaura abierto al reaparecer. Volver a un farol anterior no hace retroceder la reaparición. Reiniciar rearma las dianas y repone las tres llaves. El intento aún no se guarda al cerrar la aplicación. [Reglas de llaves](LLAVES_Y_PUERTAS.md).

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

`user://progress.json` guarda el estado completado, número de finalizaciones, máximos de hojas, cristales y llaves y mejor tiempo por identificador. Se escribe primero un temporal; rejugar conserva los mejores resultados y el acceso al nivel. Los ajustes de control se guardan por separado.

La CI exige 264 comprobaciones: 88 del protagonista, 63 de objetos, 58 del bosque y 55 de puentes. Incluyen ruta completa, gestos normales e intercambiados, teclado, impactos físicos, recuperación por escalones, pérdida y daño con piñas, pausa durante la apertura, reaparición, tres llaves y resultados rejugables. Captura el escenario real con Compatibility en 1280×720, tablet 1024×768 y panorámico 1600×720.

El tiempo con un niño de 10 años y el mínimo de 15 minutos de aventura no están medidos. La integración amplía el prototipo actual; el recorrido largo sigue requiriendo contenido y pruebas.

El objetivo es 60 FPS. Las pruebas automatizadas y las capturas no son una medición de rendimiento en un teléfono físico. Queda pendiente la prueba física de instalación, tacto y rendimiento en el móvil del usuario.

