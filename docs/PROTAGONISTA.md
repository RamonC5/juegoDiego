# Protagonista: Diego

Diego es la propuesta de protagonista de Salto Heroes basada en la fotografía aportada por el usuario. Tiene pelo oscuro y gafas negras, con ropa de aventura adaptada al acabado raster 2D del reparto. [Ficha e imagen](../art/characters/diego/ficha.md).

La escena de arranque abre una **zona de entrenamiento** con el protagonista, plataformas, una esfera recogible y dos dianas geométricas. Permite comprobar controles, salto, pisotón y lanzamiento. Los ocho mundos, sus niveles rejugables, los seis enemigos del catálogo y los jefes continúan como desarrollo posterior.

## Controles para jugar

| Acción | Android y tablet Windows | Teclado inicial | Mando |
| --- | --- | --- | --- |
| Moverse | Flechas de la izquierda | A / D o flechas | Cruceta o palanca izquierda |
| Saltar | Botón Saltar; mantener para mayor altura | Espacio | A |
| Recoger / lanzar | Botón Coger / lanzar, una pulsación | E | X |
| Correr | Automático de inicio; botón Correr si se desactiva | Mayús | B |
| Pausar / ajustar | Botón Pausa | Escape | Start |

En **Pausa y controles** se pueden cambiar las teclas, activar carrera automática, usar salto completo con una pulsación, intercambiar los lados y ajustar el tamaño de los botones. Los ajustes se guardan en `user://controls.cfg`, separados del futuro progreso. Android siempre ofrece los botones táctiles; en Windows se muestran de inicio y pueden ocultarse. Arrastrar fuera de un botón, cancelar un contacto, pausar o perder el foco libera los controles.

Los botones admiten contactos simultáneos para desplazarse, saltar y actuar. Se adaptan al área segura de Android y a la relación de aspecto. Hay etiquetas visibles, contraste alto, foco de teclado, navegación de mando y un menú con desplazamiento. No se usan sacudidas, destellos ni parpadeos de daño. La compatibilidad con lectores de pantalla nativos no está certificada.

## Movimiento inicial

| Parámetro | Valor de partida |
| --- | --- |
| Caminar / correr | 210 / 330 px/s |
| Aceleración en suelo / aire | 1900 / 1100 px/s² |
| Frenado en suelo | 2400 px/s² |
| Gravedad / límite de caída | 1700 px/s² / 900 px/s |
| Impulso de salto / rebote | 620 / 470 px/s hacia arriba |
| Tolerancia al abandonar un borde | 0,12 s |
| Anticipación antes de aterrizar | 0,14 s |
| Energía / protección tras daño | 3 / 1,2 s |
| Alturas medidas en la prueba | Pulsación corta: 36,12 px; mantenida: 107,98 px |

Se ajustan en `game/features/player/default_tuning.tres` y `player_tuning.gd`. La cápsula de colisión mide 38 × 98 px; el arte de pie ocupa aproximadamente 112 px de alto. La forma de la imagen no define colisiones ni daño.

## Animaciones

| Estado | Hoja fuente e índices desde cero | FPS | Uso |
| --- | --- | --- | --- |
| `idle` | idle, 0–3 | 6 | Respiración y parpadeo, bucle |
| `walk` | walk, 0–5 | 9 | Caminar, bucle |
| `run` | run, 0–5 | 13 | Correr, bucle |
| `jump_up` | jump, 0–1 | 10 | Impulso y ápice; mantiene última pose |
| `fall` | jump, 2 | 8 | Pose de descenso |
| `land` | jump, 3 | 10 | Pose de aterrizaje durante 0,10 s |
| `carry_idle` | grab, 3 | 6 | Pose de sostener en reposo o en el aire |
| `carry_run` | carry, 0–3 | 10 | Paso con manos ocupadas, bucle |
| `grab` | grab, 0–3 | 12 | Recogida en el fotograma 2 |
| `throw` | throw, 0–3 | 12 | Suelta en el fotograma 2 |
| `hurt` | hurt, 0–3 | 10 | Sobresalto y recuperación |
| `defeated` | defeated, 0–3 | 8 | Derrota amable y pose final |
| `victory` | victory, 0–3 | 8 | Celebración y pose final |

Son diez hojas y 44 poses fuente. Los estados que contienen una pose se identifican como tales. Las hojas cuadradas miden 1254 × 1254; caminar y correr miden 1536 × 1024. El pivote virtual es [512, 900] en 1024 × 1024, con escala uniforme por hoja y regiones explícitas que conservan las poses completas. `AtlasTexture.filter_clip` evita mezclar bordes vecinos; el shader de alfa descarta ruido de baja opacidad. El presupuesto RGBA8 sin compresión de las diez hojas ronda 60 MiB; no es una medición de VRAM en un teléfono.

## Piezas reutilizables

- `game/features/player/diego.tscn`: cuerpo, entrada, representación, punto de agarre y sensores.
- `player_input.gd`: intenciones de teclado, mando y contactos, sin teclas concretas en la física del jugador.
- `game/core/contracts/stomp_target.gd`: acepta descenso desde arriba y emite `stomped`; el futuro enemigo responde a esa señal.
- `game/features/objects/throwable_object.gd`: estados libre, recogido y lanzado; un impacto lanzado solo es válido durante el vuelo.
- `game/core/services/control_settings.gd`: opciones y reasignación persistentes; conserva los eventos de mando.
- `game/ui/touch_controls/touch_controls.gd`: punteros independientes, cancelación, zona segura y distribución.

Los jefes futuros podrán implementar `receive_thrown_hit(object)` y decidir su vulnerabilidad. Las dianas actuales solo sirven para entrenar; no definen enemigos ni jefes nuevos.

## Comprobar y producir de nuevo

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 8
godot --headless --fixed-fps 60 --path . --script tools/tests/test_player.gd
python tools/build_diego_atlas.py
```

El último comando reconstruye `SpriteFrames` y escalas desde `art/characters/diego/atlas_layout.json`, sin modificar los PNG. Solo al cambiar imágenes, `--discover` propone regiones que deben revisarse. Ese descubrimiento necesita Pillow, NumPy y SciPy fuera del juego. Para capturas, `godot --audio-driver Dummy --path . --script tools/tests/capture_player.gd` requiere una sesión gráfica o Xvfb.

Las 27 pruebas cubren movimiento, tolerancias de salto, pisotón, recoger/lanzar, daño, derrota, reaparición, tres contactos simultáneos, pausa, cambio de lados y reasignación sin perder el mando. La CI las ejecuta antes de exportar el APK. Las capturas verifican el renderizado en Compatibility y dos proporciones; no sustituyen la comprobación de tacto, rendimiento y GPU en Android y tablet Windows físicos.
