# Revisión del bosque · 0.7.2

Base: `main` en `6aaa83581b58f4737bddf7e236733686fee6f9d4`.

El tótem y la liana son PNG RGBA de 1024 × 1536 generados con image_gen; se conservan los prompts exactos. El validador de lectura confirma formato, alfa, dimensiones y contenido. Se usa `--min-padding 0` para estos elementos ambientales: la liana se une a la rama por el borde superior y ambos recursos contienen alfa residual tenue. El shader `forest_asset_alpha.gdshader` elimina ese residuo y conserva el tinte y la transparencia de las señales. No son hojas de animación de personajes.

Pruebas de Godot 4.7.2: la gruta incluye descenso real, trayecto de más de 1100 px bajo tierra, recogida sin teletransporte, ascensor visible por delante del fondo y salida por el techo. El recorrido completo conserva las tres llaves y enlaza las cinco lianas con controles reales. Los movimientos de enemigos mantienen sensores, combate, pausa y espejo; 198 comprobaciones correctas de animación. Las fichas JSON pasan su validador documental.

Compatibility y Mesa llvmpipe: capturas de móvil 1280 × 720, tablet 1024 × 768 y formato ancho 1600 × 720. Se revisaron tótem, túnel, ascensor y lianas en el escenario real. La revisión detectó y corrigió el orden de dibujo del ascensor y un resplandor que perdía su transparencia. El visor guarda 24 poses y comprueba píxeles del raster sin mover el cuerpo completo.

Pendiente: tacto, valoración del movimiento, descubrimiento del secreto y rendimiento en Android y tablet Windows físicos. Duración de primera partida pendiente; el tiempo simulado de una ruta automatizada no la mide.

## Recuento verificado dentro del APK

Actions 141 exportó y firmó correctamente el APK. La prueba del emulador falló al buscar el marcador histórico `enemies=81 art=81`; logcat confirmó el arranque real con `enemies=45 art=45`, sin errores de script. `test_android_apk.py` ahora calcula el recuento desde `enemy_spawns` del recurso actual y exige que coincidan instancias y texturas. La regresión comprueba el registro observado, un recuento antiguo, arte incompleto, cifras con prefijo coincidente, cambios de contenido y datos ausentes/vacíos. Se ejecuta antes de las pruebas Godot en CI.
