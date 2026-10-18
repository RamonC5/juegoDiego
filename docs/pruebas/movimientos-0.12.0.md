# Lanzamiento aéreo y trepa manual · 0.12.0

Petición del 18-10-2026. Base contrastada: `main`, commit `603b71bc0d5de7c92f73a39efbfbf1393ba4dc30`. Motor oficial Godot 4.7.2, descarga comprobada contra el SHA-512 fijado por el proyecto.

## Comportamiento

- Lanzar durante ascenso o descenso mantiene control horizontal y permite el segundo salto. La animación libera un solo objeto en su fotograma 2, incluso al encadenar el segundo impulso.
- Mantener arriba en la zona táctil de movimiento permite trepar por la liana a 160 px/s, combinable con el balanceo lateral. Soltar conserva la altura. W / ↑ son reasignables; la cruceta y palanca hacia arriba ofrecen el mismo control.
- Las manos siguen la cuerda a la altura alcanzada. La subida se limita antes del anclaje y ante techos sólidos; las plataformas unilaterales permiten ascender desde abajo. Saltar conserva el impulso tangencial a la altura de salida y un impulso aéreo disponible.
- Cancelación, cambio de lados, pausa, teclas mantenidas al reanudar y reaparición limpian las órdenes correspondientes. Se conservan los datos del nivel, los tres puntos de guardado, los IDs y los guardados existentes.

## Evidencia local

Importación y arranque sin errores de scripts. Suites ejecutadas con `--headless --fixed-fps 60`:

| Suite | Comprobaciones | Fallos |
| --- | ---: | ---: |
| `test_player.gd` | 111 | 0 |
| `test_player_movement.gd` | 55 | 0 |
| `test_throwables.gd` | 63 | 0 |
| `test_lianas_dianas.gd` | 16 | 0 |
| `test_forest_route.gd` | 40 | 0 |
| `test_real_recovery.gd` | 53 | 0 |
| `test_checkpoint_recovery.gd` | 26 | 0 |
| `test_bridges.gd` | 55 | 0 |
| `test_moving_platforms.gd` | 27 | 0 |
| `test_secret_grove.gd` | 21 | 0 |
| `test_gameplay_polish.gd` | 68 | 0 |
| `test_breakable_targets.gd` | 42 | 0 |
| `test_forest.gd` | 64 | 0 |
| `test_forest_expansion.gd` | 76 | 0 |
| `test_collection_rewards.gd` | 54 | 0 |
| `test_reward_presentation.gd` | 51 | 0 |
| `test_audio_respawn.gd` | 34 | 0 |
| `test_enemy_motion.gd` | 198 | 0 |
| `test_entrance.gd` | 3939 | 0 |

También pasan las 12 pruebas de preparación Android y la validación documental de las ocho fichas existentes, admitidas como legado versión 1. No se han añadido diseños de nivel nuevos ni validaciones de secretos.

## Capturas y límites

La CI ejecuta las mismas suites antes de exportar. `capture_player_movement.gd` añade las vistas `vine_climb_detail`, `air_throw` y `air_throw_release`, además de las anteriores de agarre, espejo y doble salto. El resultado de exportación, firma y emulador corresponde al run de GitHub del commit de integración; no se atribuye aquí una ejecución todavía pendiente. El tacto, la comodidad del gesto y el rendimiento en Android y Windows físicos requieren prueba en los dispositivos del usuario.
