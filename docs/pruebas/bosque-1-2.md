# Verificación de Bosque 1-2

Base revisada: `main`, `02b7e656b7de0c443804a5fe6744d4fd56cf6cf6` (0.12.0). Implementación en `feat/forest-level-2`, con Godot 4.7.2 oficial y Compatibility. No se ha cambiado `level_01.tres` ni su generador.

- `test_forest_level_02.gd`: 79 comprobaciones correctas. Recorre los 16 tramos desde el inicio hasta la puerta sin teletransportes, usando movimiento, saltos, rebotes, viaje en troncos, lanzamientos y agarre entre las cinco lianas de cada cruce. Obtiene las tres llaves y los tres cristales por contacto físico. Los enemigos se aíslan para verificar la geometría; no acredita combate real ni primera partida infantil.
- La misma suite comprueba desbloqueo con `progress.json` v1, rechazo de rutas desconocidas, selector, HUD 1-2, exactamente tres faroles, salud parcial conservada al tocarlos, colección única persistente y resultado independiente.
- `test_entrance.gd`: 3940 comprobaciones correctas del flujo de entrada, mapa, selector, primer nivel y retorno, con eventos táctiles reales. Los siete mundos restantes siguen bloqueados.
- Comprobador de fichas con `--actual`: nivel y setas coherentes. Secreto pendiente declarado; ficha de nivel en estado `ampliacion`.
- 24 pruebas Python del comprobador y 12 de preparación Android correctas.

La ruta protegida dura 500,6 segundos simulados; el presupuesto de 18–22 minutos sigue siendo una estimación pendiente de observación. No se han realizado pruebas físicas nuevas en Android o Windows. La CI incluye capturas reales del selector en 1280×720 y 960×540, de las setas, la copa y las lianas, y comprueba los datos binarios de ambos niveles dentro del APK.

Pendiente: validación del usuario sobre ubicación y actividad del secreto, construcción posterior y pruebas de entrada/retorno/recompensa; revisión visual de capturas de CI y prueba física de rendimiento y tacto. No se declara completa la aventura mientras falte el secreto obligatorio de autoría.
