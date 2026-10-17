# Super Diego 0.6.0 · Música y reaparición

Validación local del 17 de octubre de 2026 con Godot 4.7.2, sobre `main` en `99e2d98`. La entrega añade música, recuperación de patrullas y señales sin letras; conserva los datos físicos del recorrido.

| Suite | Comprobaciones correctas |
| --- | ---: |
| Protagonista y controles | 89 |
| Objetos arrojadizos | 63 |
| Animación de enemigos | 140 |
| Nivel y llaves | 61 |
| Dianas y puentes | 55 |
| Troncos móviles | 27 |
| Bosque ampliado | 105 |
| Pulido y persecución | 68 |
| Ruta geométrica completa | 70 |
| Audio y reaparición | 33 |
| **Total** | **711** |

Las suites terminan sin fallos ni errores de script. La nueva suite verifica enemigos derrotados por pisotón y lanzamiento, antes del primer farol y después de activarlo, nodos ya liberados, animaciones de derrota pendientes, regreso a faroles anteriores, repetición sin duplicados y progreso conservado. Comprueba reproducción, bus, bucle, pausa, silencio y un solo reproductor por escena, además de ausencia de letras visibles en el escenario.

FFprobe confirma Vorbis estéreo a 44.100 Hz, 71,111 segundos y 659.835 bytes. La señal decodificada tiene pico de −2,09 dBFS, RMS de −15,19 dBFS y diferencia de muestras en la unión de aproximadamente 0,00115. La partitura original y la síntesis reproducible están en `tools/authoring/compose_forest_music.py`; no usa samples de terceros. El constructor del nivel conserva la referencia musical al regenerar sus datos.

Las pruebas rápidas conceden 120 ms al mezclador antes de cerrar para vaciar las voces asíncronas, por el [problema de cierre de AudioStreamPlayer documentado por Godot](https://github.com/godotengine/godot/issues/76745). El servicio detiene y libera su stream al abandonar la escena. Este tiempo adicional solo pertenece a las herramientas de pruebas, sin esperas añadidas a la partida.

La duración real de la aventura y la escucha con altavoces de Android y Windows físicos siguen pendientes. Las pruebas headless verifican el comportamiento del audio; no evalúan su calidad perceptiva ni el volumen de un dispositivo concreto.
