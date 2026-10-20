# Bosque 1-3 y Nudor · Validación de 0.15.0

Base: `main` en `1a409cf`; rama local `feat/forest-level-3-nudor`, 20-10-2026. Godot 4.7.2 estándar oficial, checksum SHA-512 cotejado con el proyecto. Sin autoloads nuevos.

## Pruebas observadas

| Suite | Resultado | Alcance |
| --- | --- | --- |
| `test_forest_level_03.gd` | 80 comprobaciones, 0 fallos | Ruta con entradas reales, setas, troncos, puentes, lianas, tres llaves y cristales, faroles sin curación y colección persistente. Enemigos aislados para verificar geometría. |
| `test_nudor.gd` | 68 comprobaciones, 0 fallos | Acceso, HUD en tres tamaños, pausa, daño válido, colisión desde arriba, evasión/daño del manotazo y barrido, reintentos, munición y cinco lanzamientos aéreos reales; victoria única guardada. |
| Ficha `world_01_level_03.json --actual` | Correcta | Versión 2, 18–22 minutos estimados, tres faroles sin curación, colección máxima en nivel 3 y secreto pendiente. |

La ruta protegida de 1-3 tarda **518,3 segundos simulados**. No equivale a una muestra humana ni acredita el presupuesto de primera partida. La CI incorpora las dos suites y comprobaciones de los datos de 1-3/Nudor dentro del APK; no se afirma una ejecución remota de esta revisión local.

Regresiones locales correctas, sin errores de scripts: `test_throwables`, `test_player_movement`, `test_enemy_motion`, `test_checkpoint_recovery`, `test_real_recovery`, `test_collection_rewards`, `test_forest_level_02` y `test_entrance`. Las 24 pruebas Python del comprobador de dinámicas también pasan.

## Arte y revisión gráfica

Dos ediciones con `image_gen`, conservando identidad y poses cerrada/abierta. PNG de 1774 × 887, RGBA, dos celdas de 887 × 887. El comprobador estricto no pasa: quedan píxeles de alfa 1–16 fuera de la silueta. No se ha ocultado el fallo ni editado el PNG con otro editor.

El shader existente descarta alfa inferior a 0,13. Con ese umbral, los límites visibles son (152,137)–(770,788) y (120,154)–(781,788), con al menos 99 px libres. [Informe](../../art/characters/nudor/qa-poses-v001.json). Se revisó el raster; eso no certifica la animación en el motor.

`capture_forest_level_03.gd` prepara vistas del recorrido, arena, avisos, apertura, barrido, pausa, móvil y selector. **Revisión gráfica pendiente**: el servidor de pantalla no quedó accesible para Godot. Headless no se presenta como captura ni prueba física.

## Pendientes

- Validar ubicación y actividad de la gruta antes de construirla. Ficha en `ampliacion`; secretos desactivados.
- Revisar un ciclo de brazos/manos, apoyos, apertura y derrota en Compatibility y el dibujo de las zonas dañinas.
- Medir dificultad, ventanas y duración con primeras partidas del público objetivo.
- Probar tacto, mando, audio y rendimiento en Android y Windows físicos. No se ha exportado ni distribuido APK en esta sesión.

## Reproducir

```sh
godot --headless --path . --editor --import --quit
godot --headless --fixed-fps 60 --path . --script tools/tests/test_forest_level_03.gd
godot --headless --fixed-fps 60 --path . --script tools/tests/test_nudor.gd
godot --rendering-method gl_compatibility --path . --script tools/tests/capture_forest_level_03.gd
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py --actual docs/niveles/world_01_level_03.json
```
