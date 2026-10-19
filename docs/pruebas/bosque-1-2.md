# Verificación de Bosque 1-2

Base revisada: `main`, `02b7e656b7de0c443804a5fe6744d4fd56cf6cf6` (0.12.0). Implementación en `feat/forest-level-2`, con Godot 4.7.2 oficial y Compatibility. No se ha cambiado `level_01.tres` ni su generador.

- `test_forest_level_02.gd`: 79 comprobaciones correctas. Recorre los 16 tramos desde el inicio hasta la puerta sin teletransportes, usando movimiento, saltos, rebotes, viaje en troncos, lanzamientos y agarre entre las cinco lianas de cada cruce. Obtiene las tres llaves y los tres cristales por contacto físico. Los enemigos se aíslan para verificar la geometría; no acredita combate real ni primera partida infantil.
- La misma suite comprueba desbloqueo con `progress.json` v1, rechazo de rutas desconocidas, selector, HUD 1-2, exactamente tres faroles, salud parcial conservada al tocarlos, colección única persistente y resultado independiente.
- `test_entrance.gd`: 3940 comprobaciones correctas del flujo de entrada, mapa, selector, primer nivel y retorno, con eventos táctiles reales. Los siete mundos restantes siguen bloqueados.
- Comprobador de fichas con `--actual`: nivel y setas coherentes. Elección real del secreto registrada; ficha implementada con evidencia de recorrido y capturas.
- 24 pruebas Python del comprobador y 12 de preparación Android correctas.

La ruta protegida dura 500,6 segundos simulados; el presupuesto de 18–22 minutos sigue siendo una estimación pendiente de observación. No se han realizado pruebas físicas nuevas en Android o Windows. La CI incluye capturas reales del selector en 1280×720 y 960×540, de las setas, la copa y las lianas, y comprueba los datos binarios de ambos niveles dentro del APK.

## Ampliación del 19-10-2026: secreto de las copas

`test_canopy_secret.gd` prepara el inicio junto al primer farol y recorre por controles la entrada, agarre, trepa manual, salto a la copa, cinco árboles, vida extra y tres ramas de bajada. Comprueba pausa, ausencia de trepa automática, límite de la liana larga, reentrada sin premio duplicado, muerte, registro único de liana y reapertura de colección. El recurso exportado se verifica también dentro del APK. Capturas reales adicionales: acceso, copas, premio y descenso.

La versión final pasa **29 comprobaciones locales, 0 fallos**, con Godot 4.7.2 oficial. La entrada y la trepa se prueban con enemigos activos y sin invulnerabilidad; el resto aísla geometría. Capturas reales Compatibility de entrada, agarre alto, copas, brote y descenso revisadas: apoyos, manos, HUD y acabado raster legibles. La captura de trepa exige agarre físico real.

[CI 192](https://github.com/RamonC5/juegoDiego/actions/runs/39202228898) completó todas las suites del recorrido base, 79 comprobaciones de 1-2, 28 del secreto antes del acabado final, 17 de datos binarios del APK y la instalación y gestos en emulador Android. El acabado final añade el roble completo, ramas en lugar de tierra, anclaje visible y guardia apartado de la entrada. La nueva exportación se sigue desde el PR #2; no se atribuye al APK anterior este acabado posterior.

Tras la espera de ejecutor en Ubuntu 24.04, la misma CI usa Ubuntu 22.04 para la exportación final. Se conservan Godot, plantillas, Java 17, SDK, firma, pruebas y comprobaciones. Permanecen pendientes las partidas con el público objetivo y las pruebas físicas de rendimiento y tacto en Android/Windows.

