# Recuperación por farol y avance agachado · 0.7.4

Corrección solicitada el 17 de octubre de 2026 sobre `main`, base `8db86aab024c00617d51c5c470e4d324a3a2821e`.

## Fallos y comportamiento corregido

Agacharse fijaba la velocidad a cero mientras `can_stand()` impedía levantarse bajo un techo: no había forma de salir. Ahora la cápsula baja permite avanzar y retroceder a 90 px/s y recupera la postura al disponer de espacio. Un contacto táctil puede deslizar abajo y después arrastrar horizontalmente. La postura no reclama el eje hasta empezar ese arrastre, para permitir también moverse con otro dedo. Se mantienen el frenado, las reglas de daño, la carrera automática y el descarte de saltos pendientes.

La reaparición cerraba todos los puentes y portones, reconstruía todas las dianas y reiniciaba los ciclos sin considerar el farol alcanzado. Ahora conserva lo anterior al punto de reaparición y rearma únicamente lo posterior. Las dianas y piñas pertenecen al puzzle que accionan, por lo que se restablecen juntas aunque una estación esté antes del farol y controle una barrera posterior. Se aplica la misma frontera a objetos generales, ciclos móviles y patrullas por su origen. Sin farol se reinicia desde el comienzo.

Al activar otro farol se consolidan únicamente las derrotas anteriores a él. Un enemigo posterior eliminado desde lejos sigue pendiente de reaparecer. Eliminar un enemigo al volver a una zona anterior conserva esa derrota. Los reintentos repetidos mantienen una instancia por puesto y no duplican activaciones ni el marcador. Las llaves, hojas, cristales y el corazón secreto conservan la persistencia del intento.

## Validación local

Godot **4.7.2**, 60 pasos físicos por segundo, escenas y controladores reales. **855 comprobaciones correctas, 0 fallos**, más arranque correcto y cuatro regresiones Python del comprobador Android. Las siete fichas JSON afectadas pasan el validador documental.

| Suite | Comprobaciones | Fallos |
| --- | ---: | ---: |
| `test_audio_respawn.gd` | 34 | 0 |
| `test_breakable_targets.gd` | 41 | 0 |
| `test_bridges.gd` | 55 | 0 |
| `test_checkpoint_recovery.gd` | 26 | 0 |
| `test_enemy_motion.gd` | 198 | 0 |
| `test_forest.gd` | 64 | 0 |
| `test_forest_expansion.gd` | 71 | 0 |
| `test_forest_route.gd` | 40 | 0 |
| `test_gameplay_polish.gd` | 68 | 0 |
| `test_lianas_dianas.gd` | 16 | 0 |
| `test_moving_platforms.gd` | 27 | 0 |
| `test_player.gd` | 101 | 0 |
| `test_player_movement.gd` | 30 | 0 |
| `test_secret_grove.gd` | 21 | 0 |
| `test_throwables.gd` | 63 | 0 |

El techo se mantiene físicamente presente durante las pruebas de avance, marcha atrás y salida; no se retira para permitir levantarse. Los contactos táctiles llegan al controlador y a la física del protagonista. La recuperación se prueba antes de cualquier farol, entre puzzles y con un farol situado entre una diana y su portón, además de muertes consecutivas, derrotas ya liberadas, objetos y ciclos a ambos lados de la frontera.

Para la ejecución local se reutilizaron los recursos importados del APK válido de Actions 145 junto con los scripts modificados. La CI de este cambio importa los PNG fuente, ejecuta las suites, genera las capturas Compatibility y compila/prueba el APK actualizado. Este registro local no equivale a haber probado ese APK en un teléfono o en una tablet Windows físicos; tacto y rendimiento en esos dispositivos quedan pendientes.

## Revisión manual en dispositivo

Entrar agachado bajo un bloque, soltar abajo, arrastrar en ambas direcciones y salir por cada extremo. Repetir manteniendo abajo y moviendo el mismo dedo, así como con dos contactos. Abrir un puente, alcanzar el farol siguiente, resolver otro puzzle posterior y morir: el primero debe conservar su paso y el segundo debe volver a estar pendiente. Volver atrás y comprobar acceso, llaves y ausencia de duplicados.
