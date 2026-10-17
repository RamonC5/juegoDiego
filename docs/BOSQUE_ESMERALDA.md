# Bosque Esmeralda · 1-1

**El despertar del bosque** es el primer nivel jugable de Salto Heroes, para Android y Windows. Se abre al iniciar el juego; el entrenamiento anterior sigue accesible desde Pausa.

![Bosque Esmeralda: árboles con musgo, luz cálida y profundidad de fondo](../game/assets/textures/environments/bosque_esmeralda/forest_backdrop_v001.png)

## Recorrido

| Tramo en píxeles lógicos | Experiencia |
| --- | --- |
| 0–1700 | Espacio seguro inicial, primera llave de ramas en x=820, hojas, barril y dos encuentros de Terrón |
| 1820–2850 | Moflete, plataforma opcional y farol de ensayo en x=2470; piña en x=2540 y diana en x=2780 |
| 2850–3270 | Pasarela de ensayo de 420 px, suelo inferior y escalones de retorno |
| 3270–3790 | Farol en x=3390, piña en x=3430 y diana principal en x=3710 |
| 3790–4270 | Puente de raíces de 480 px, abierto mediante lanzamiento |
| 4270–5100 | Llave 2 en x=4560, farol en x=4820, patrulla y ruta opcional al cristal alto |
| 5220–6280 | Vasija, ensayo de tronco horizontal sobre suelo seguro y ruta opcional al cristal |
| 6330–6900 | Tronco ascendente, repisa y tercera llave en `(6760,211)`; suelo inferior para reintentar |
| 7020–8200 | Último hueco de salto, tres patrullas y puerta en x=7900, que exige tres llaves |

Las tres brechas normales miden 120 px; los dos pasos amplios requieren activar sus dianas. La [dinámica del puente de raíces](dinamicas/puente_diana.md) reutiliza la recogida y el lanzamiento: un toque coge una piña y otro la lanza. La diana acepta cualquier arrojadizo válido. El ensayo ofrece suelo inferior y apoyos de retorno, probados con saltos reales. Las piñas perdidas vuelven a sus puestos.

Volver al farol conserva llaves, hojas, cristales y puentes resueltos del intento. Un despliegue interrumpido se restaura abierto al reaparecer. Volver a un farol anterior no hace retroceder la reaparición. Reiniciar rearma las dianas y repone las tres llaves. El intento aún no se guarda al cerrar la aplicación. [Reglas de llaves](LLAVES_Y_PUERTAS.md).

La segunda dinámica, [Troncos viajeros](dinamicas/troncos_viajeros.md), enseña a embarcar, dejarse transportar y saltar a una repisa. Un ensayo horizontal precede al ascensor de la tercera llave. Las plataformas tienen paradas amplias y se atraviesan desde abajo; caer permite volver desde el suelo. Al reaparecer, los ciclos vuelven al puesto inicial después de trasladar a Diego al farol.

Se mantienen ocho identificadores de mundo. Esta entrega incorpora solo `world_01_level_01`; no crea los otros siete mundos ni un jefe del bosque.

## Dos encuentros adicionales · versión 0.4.1

| Enemigo | Puesto y patrulla | Papel |
| --- | --- | --- |
| Terrón | `(1010,600)`, x=990–1030 | Añadir combate después de recoger la primera llave, antes del barril. |
| Moflete | `(7180,600)`, x=7160–7200 | Recuperar el combate después de las dinámicas y antes del arco de salida. |

El nivel pasa de siete a nueve instancias de los dos enemigos ya integrados. Se ajusta el límite izquierdo de la patrulla de Terrón del tramo final a x=7310 para separar los cuerpos. Las patrullas nuevas permanecen sobre suelo firme y no ocupan dianas, piñas, apoyos de recuperación, faroles ni puestos de embarque. No se exige derrotarlas para abrir la puerta: conserva las tres llaves como condición.

La [CI de 0.4.1](https://github.com/RamonC5/juegoDiego/actions/runs/39009974004), sobre `ea199673aaea6914a0134b248416e1d48d068d85`, supera 294 comprobaciones, incluidos los pisotones de las dos instancias nuevas y el recorrido completo con nueve enemigos activos. Genera capturas de ambos encuentros y un APK firmado. Las capturas se han revisado.

El usuario informó el 17 de octubre de 2026 de una partida completa de **45 segundos** en la versión anterior. Se registra como observación del usuario, sin una nueva medición ni una atribución de edad o metodología. Esta entrega añade dos encuentros; ampliar el recorrido hasta el mínimo de 15 minutos continúa pendiente.

## Visibilidad de enemigos en Android · versión 0.4.2

Se corrige la pérdida de `enemy_kinds` al convertir el nivel a recurso binario: los tipos usan `Array[String]` y se comprueban dentro del APK exportado. El primer Terrón se identifica con «Enemigo · Terrón / Salta encima» y Pausa muestra la versión de compilación. La validación de 0.4.2-ci.37 instala el APK ARM64 en emulador Android y confirma nueve patrullas con arte cargado; se revisa su visibilidad. [Diagnóstico, evidencia y límites](pruebas/apk-enemigos-0.4.2.md).

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

La CI exige 294 comprobaciones: 88 del protagonista, 63 de objetos, 61 del bosque, 55 de puentes y 27 de troncos viajeros. Incluyen ruta completa, gestos normales e intercambiados, teclado, impactos físicos, recuperación por escalones, pérdida y daño con piñas, pausa durante la apertura, reaparición, tres llaves y resultados rejugables. Captura el escenario real con Compatibility en 1280×720, tablet 1024×768 y panorámico 1600×720.

El tiempo con un niño de 10 años y el mínimo de 15 minutos de aventura no están medidos. La integración amplía el prototipo actual; el recorrido largo sigue requiriendo contenido y pruebas.

El objetivo es 60 FPS. Las pruebas automatizadas y las capturas no son una medición de rendimiento en un teléfono físico. Queda pendiente la prueba física de instalación, tacto y rendimiento en el móvil del usuario.


