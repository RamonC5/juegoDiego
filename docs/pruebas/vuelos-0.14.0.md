# Vuelos entre lianas · Super Diego 0.14.0

Base: `main` en `34b801483975894e0f273247720c3c4a72e3c865`. Motor fijado: Godot 4.7.2, verificado contra el checksum del proyecto. Petición del 19-10-2026: nueva dinámica con algo más de complejidad en Bosque 1-2 y varios murciélagos que vuelan sin perseguir.

## Contenido

Se reutiliza Nóctilo y su aleteo raster articulado. Ocho vuelos nuevos al final de `enemy_spawns` conservan los 58 índices terrestres anteriores. Todos repiten rutas horizontales con giros suaves, oscilación vertical de 12 px, fases distintas y periodos de 12–14 segundos. La velocidad máxima de autoría es menor de 135 px/s. La primera observación tiene suelo firme; después hay dos vuelos en el primer cruce y tres en cada cruce posterior. No se modifica el secreto de las copas, la colección ni las tres llaves/faroles.

| Tramo, desde cero | Límites X locales y altura de origen Y |
| --- | --- |
| 2 · Ensayo | 1450–1830 / 365; 2200–2650 / 510 |
| 9 · Combinación | 1960–2320 / 500; 2440–2770 / 355; 2820–3150 / 515 |
| 13 · Variación | 1910–2240 / 515; 2390–2720 / 360; 2820–3150 / 480 |

Cada origen de tramo suma `índice × 4800` a X. La colisión corporal mide 54 × 40 px, independiente de las alas. El contacto lateral usa daño, invulnerabilidad y liberación de liana existentes. El sensor superior permite pisotón y rebote; el contrato compartido permite impactos de objetos lanzados. Derrotarlos es opcional. La pausa detiene cuerpo y alas; la recuperación conserva derrotas anteriores al farol y repone las posteriores.

## Comprobación local observada

- Importación y análisis de scripts con Godot fijado: correctos.
- `test_bat_flights.gd`: 33 comprobaciones, cero fallos. Ruta independiente de Diego durante 900 pasos, límites de los ocho vuelos durante dos ciclos, pausa, recorrido físico de las cinco lianas del ensayo con los dos vuelos activos y sin invulnerabilidad ni daño, contacto lateral, salida del agarre, pisotón, rebote y recuperación a ambos lados del farol.
- `test_forest_level_02.gd`: 79 comprobaciones, cero fallos. Ruta completa, tres llaves, faroles sin curación, cristales y guardado. Aísla enemigos para verificar geometría; no acredita dificultad de los vuelos.
- `test_enemy_motion.gd`: 198 comprobaciones, cero fallos.
- `test_checkpoint_recovery.gd`: 26 comprobaciones, cero fallos.
- `test_canopy_secret.gd`: 29 comprobaciones, cero fallos.
- Fichas versión 2: consistentes con `--actual`; 24 pruebas del comprobador documental correctas.

La CI incluye la suite nueva, capturas de los tres cruces en Compatibility y comprobación de los ocho tipos/rutas dentro del recurso binario del APK.

## Límites

La prueba con daño real cubre el ensayo; los otros dos cruces requieren observar ventanas y ajustar altura. Su dificultad con un niño de 10 años y las pruebas en Android/Windows físicos siguen pendientes. La ruta automática protegida mantiene 500,6 s simulados: no mide duración humana. No se ha generado arte nuevo ni añadido otro secreto.
