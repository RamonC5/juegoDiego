# Protagonista: Diego

Diego es la propuesta de protagonista de Super Diego basada en la fotografía aportada por el usuario. Tiene pelo oscuro y gafas negras, con ropa de aventura adaptada al acabado raster 2D del reparto. [Ficha e imagen](../art/characters/diego/ficha.md).

La escena de arranque abre **Bosque Esmeralda 1-1**, y Pausa permite volver a la **zona de entrenamiento** con el protagonista, plataformas, [seis objetos arrojadizos](OBJETOS_ARROJADIZOS.md) y dos dianas geométricas. Permite comprobar controles, salto, pisotón y lanzamiento. El bosque integra a Terrón y Moflete y guarda resultados rejugables; los otros niveles, mundos, enemigos y jefes siguen pendientes.

## Controles para jugar

| Acción | Android y tablet Windows | Teclado inicial | Mando |
| --- | --- | --- | --- |
| Moverse | Arrastrar horizontalmente desde cualquier punto de la mitad derecha; soltar para parar | A / D o flechas | Cruceta o palanca izquierda |
| Saltar / doble salto | Pulsar una vez en la mitad izquierda y otra vez durante el vuelo | Espacio, dos pulsaciones | A, dos pulsaciones |
| Agacharse / avanzar agachado | Deslizar abajo en la mitad derecha y arrastrar horizontalmente con el mismo dedo; soltar para levantarse cuando haya espacio | S / flecha abajo (reasignable) | Cruceta abajo o palanca izquierda hacia abajo |
| Recoger / lanzar | Toque corto en cualquier punto de la mitad derecha | E | X |
| Correr | Arrastre largo; carrera con arrastre corto opcional | Mayús o carrera automática | B o carrera automática |
| Pausar / ajustar | Botón Pausa | Escape | Start |

En **Pausa y controles** se pueden cambiar las teclas, activar carrera con arrastres cortos, usar salto completo en teclado y mando, intercambiar las mitades y ajustar el recorrido de los gestos. Los ajustes se guardan en `user://controls.cfg`, separados del futuro progreso. Android siempre permite gestos; en Windows están activados de inicio y también se pueden probar con el ratón. El ajuste anterior de tamaño se migra a recorrido, conservando las demás preferencias.

No hay botones de juego fijos. Cada dedo conserva su función al cruzar el centro; se puede mover, saltar y actuar simultáneamente. El origen horizontal sigue al dedo en arrastres largos para facilitar invertir la dirección. Cancelar un contacto, pausar o perder el foco libera la entrada correspondiente. Los trazos solo aparecen al tocar y las guías superpuestas permanecen ocultas y las instrucciones se consultan en pausa. Se respetan el área segura y la relación de aspecto. El menú conserva contraste alto, foco de teclado, navegación de mando y desplazamiento. [Referencias y detalle de los gestos](CONTROLES_TACTILES.md).

## Movimiento inicial

| Parámetro | Valor de partida |
| --- | --- |
| Caminar / correr | 210 / 330 px/s |
| Aceleración en suelo / aire | 1900 / 1100 px/s² |
| Frenado en suelo | 2400 px/s² |
| Gravedad / límite de caída | 1700 px/s² / 900 px/s |
| Impulso inicial / segundo salto / rebote | 680 / 590 / 470 px/s hacia arriba |
| Tolerancia al abandonar un borde | 0,12 s |
| Anticipación antes de aterrizar | 0,14 s |
| Energía / protección tras daño | 3 / 1,2 s |
| Alturas medidas en la prueba | Pulsación corta: 36,12 px; mantenida: 107,98 px |

Se ajustan en `game/features/player/default_tuning.tres` y `player_tuning.gd`. La cápsula de colisión mide 38 × 98 px; el arte de pie ocupa aproximadamente 112 px de alto. Agachado baja a 38 × 58 px y conserva el apoyo de los pies. La forma de la imagen no define colisiones ni daño.

Agacharse se activa sobre el suelo y permite avanzar o retroceder a 90 px/s, ajustables mediante `PlayerTuning.crouch_speed`, incluso con carrera automática. Mantener abajo durante una caída aplica la postura al aterrizar. Si un techo impide levantarse, Diego conserva la cápsula baja y puede moverse hasta salir; al soltar abajo o deslizar arriba se levanta automáticamente cuando cabe. Las plataformas atravesables desde abajo permiten levantarse debajo, sin cambiar la altura de los pies. El mismo contacto táctil puede deslizar abajo y después arrastrar a ambos lados; también se admiten dos dedos. Mantener abajo tiene prioridad sobre saltar y descarta ese salto; la energía y el daño mantienen sus reglas. El objeto sostenido baja con la mano; recoger y lanzar vuelven a estar disponibles al levantarse. Pausa y pérdida de foco liberan los contactos, y reaparecer restablece la postura.

## Animaciones

| Estado | Hoja fuente e índices desde cero | FPS | Uso |
| --- | --- | --- | --- |
| `idle` | idle, 0–3 | 6 | Respiración y parpadeo, bucle |
| `walk` | walk, 0–5 | 9 | Caminar, bucle |
| `run` | run, 0–5 | 13 | Correr, bucle |
| `jump_up` | jump, 0–1 | 10 | Impulso y ápice; mantiene última pose |
| `double_jump` | jump, 0–1 | 10 | Reinicio del impulso aéreo durante 0,18 s |
| `vine_hang` | vine_hang, pose única | 6 | Ambas manos elevadas y ancladas al nudo; giro alrededor del agarre |
| `fall` | jump, 2 | 8 | Pose de descenso |
| `land` | jump, 3 | 10 | Pose de aterrizaje durante 0,10 s |
| `carry_idle` | grab, 3 | 6 | Pose de sostener en reposo o en el aire |
| `carry_run` | carry, 0–3 | 10 | Paso con manos ocupadas, bucle |
| `grab` | grab, 0–3 | 12 | Recogida en el fotograma 2 |
| `throw` | throw, 0–3 | 12 | Suelta en el fotograma 2 |
| `hurt` | hurt, 0–3 | 10 | Sobresalto y recuperación |
| `defeated` | defeated, 0–3 | 8 | Derrota amable y pose final |
| `victory` | victory, 0–3 | 8 | Celebración y pose final |
| `crouch` | crouch, 0–3 | 5 | Postura baja con respiración, bucle |

Son doce imágenes y 49 poses fuente, con 16 estados. La pose `vine_hang` reutiliza la identidad de Diego y añade un PNG RGBA de 1254 × 1254, pivote [697, 1137], manos [697, 149] y escala 0,12. El dibujo gira alrededor de las manos y compensa la aproximación del cuerpo, también al orientarse a la izquierda. Los estados que contienen una pose se identifican como tales. Las hojas cuadradas miden 1254 × 1254; caminar, correr y agacharse miden 1536 × 1024. El pivote virtual es [512, 900] en 1024 × 1024, con escala uniforme por hoja y regiones explícitas que conservan las poses completas. `AtlasTexture.filter_clip` evita mezclar bordes vecinos; el shader de alfa descarta ruido de baja opacidad. El presupuesto RGBA8 sin compresión de las doce imágenes ronda 72 MiB; no es una medición de VRAM en un teléfono.

## Piezas reutilizables

- `game/features/player/diego.tscn`: cuerpo, entrada, representación, punto de agarre y sensores.
- `player_input.gd`: intenciones de teclado, mando y contactos, sin teclas concretas en la física del jugador.
- `game/core/contracts/stomp_target.gd`: acepta descenso desde arriba y emite `stomped`; el futuro enemigo responde a esa señal.
- `game/features/objects/throwable_object.gd`: estados libre, recogido y lanzado; un impacto lanzado solo es válido durante el vuelo.
- `game/core/services/control_settings.gd`: opciones y reasignación persistentes; conserva los eventos de mando.
- `game/ui/touch_controls/touch_controls.gd`: reconocimiento de gestos, eje analógico, punteros independientes, cancelación y zona segura.

Los jefes futuros podrán implementar `receive_thrown_hit(object)` y decidir su vulnerabilidad. Las dianas actuales solo sirven para entrenar; no definen enemigos ni jefes nuevos.

## Comprobar y producir de nuevo

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 8
godot --headless --fixed-fps 60 --path . --script tools/tests/test_player.gd
python tools/build_diego_atlas.py
```

El último comando reconstruye `SpriteFrames` y escalas desde `art/characters/diego/atlas_layout.json`, sin modificar los PNG. Solo al cambiar imágenes, `--discover` propone regiones que deben revisarse. Ese descubrimiento necesita Pillow, NumPy y SciPy fuera del juego. Para capturas, `godot --audio-driver Dummy --path . --script tools/tests/capture_player.gd` requiere una sesión gráfica o Xvfb.

Las pruebas de controles y movimientos cubren movimiento, agacharse y levantarse, techo bajo, objeto sostenido, tolerancias de salto, pisotón, recoger/lanzar, daño, derrota, reaparición, gestos analógicos, tres contactos simultáneos, cancelaciones, pausa, cambio de lados, tablet 4:3, migración de ajustes y reasignación sin perder el mando. La CI las ejecuta antes de exportar el APK. Las capturas verifican el renderizado en Compatibility y dos proporciones; no sustituyen la comprobación de tacto, rendimiento y GPU en Android y tablet Windows físicos.



