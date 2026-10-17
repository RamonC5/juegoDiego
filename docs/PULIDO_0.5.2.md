# Super Diego 0.5.2 · Persecución, HUD, salto y cámara

Petición del 17 de octubre de 2026, aplicada sobre `main@3adf995db526fb06585e6d03b1a8dfcde040a377` (0.5.1).

## Cambios implementados

- **Persecución:** Terrón y Moflete pueden dejar las plataformas y bajar hacia Diego. Mantienen el aviso de 0,42 s y los contratos de pisotón y lanzamiento. La visión alcanza 440 px hacia abajo y sigue comprobando obstáculos. Un sondeo de 720 px bajo el borde comprueba que existe apoyo inferior antes de bajar, excluyendo el cuerpo de la plataforma actual. El enemigo reconoce su apoyo actual, incluidos los troncos, y puede elegir el otro extremo cuando la primera salida no tiene suelo. Conserva la última posición vista hasta 3,5 s al investigar un descenso, sin ver a través de obstáculos. No hay saltos entre estructuras ni navegación para subirlas.
- **Después de bajar:** si pierden a Diego, patrullan desde el nuevo suelo. Volver al farol reinicia los enemigos vivos en sus orígenes. La patrulla tranquila frena ante los bordes.
- **HUD:** una fila compacta con corazón + energía, llave de ramas + cantidad, hoja dorada + cantidad y cristal esmeralda + cantidad. Textos de 26 px, contraste alto, pausa de 60 × 54 px con foco y nombre accesible, zona segura y título que se oculta cuando falta ancho. Las descripciones conservan el estado individual de las tres llaves. Todos los contadores dejan pasar los gestos y carecen de animaciones intermitentes. El corazón representa energía; no se ha añadido un sistema de vidas.
- **Salto:** impulso de 620 a 680 px/s con gravedad de 1.700 px/s². La altura balística teórica pasa de 113,1 a 136 px, aproximadamente un 20 %. La física discreta se mide en la suite del protagonista. Se conservan salto corto, salto completo accesible, tolerancia al borde, anticipación y rebote de pisotón de 470 px/s.
- **Cámara:** su posición vertical sigue `player.y - 240` en cada fotograma, dentro de los límites del nivel, sin el anterior máximo de 260 px/s. El encuadre acompaña también caídas de 900 px/s y queda congelado al pausar. No añade sacudidas.

## Validación

`test_forest_expansion.gd` comprueba patrulla tranquila y reinicio de los enemigos de las plataformas reales, además de paredes, vacío, pausa y mecanismos. `test_gameplay_polish.gd` añade una arena física sin obstáculos móviles que permite comprobar detección, descenso bilateral de ambas especies, aterrizaje, continuación de persecución, pérdida del jugador, reinicio al farol y freno ante vacío sin apoyo.

`test_player.gd` mide el salto mantenido en el motor y exige 125–142 px, además de conservar el salto corto y la opción de salto completo. Las suites de recorrido continuo comprueban el bosque con el nuevo salto y reconocen el acceso directo a la primera terraza desde el hueco anterior. La suite de troncos excluye a los enemigos para aislar transporte, gestos y recuperación; el combate se comprueba en las suites de bosque y persecución.

`test_gameplay_polish.gd` comprueba seguimiento vertical sin retraso, pausa, actualización de los cuatro contadores, descripciones de llaves, paso de gestos y HUD sin solapamiento en móvil, tablet 4:3 y pantalla panorámica. `capture_forest.gd` genera vistas reales con Compatibility para revisar el diseño.

La CI importa, arranca, ejecuta las suites, exporta el APK ARM64 y lo instala en emulador Android API 35. El enlace de la ejecución confirmada se entrega con el resultado. El tacto y el rendimiento en dispositivos físicos, el equilibrio con un niño de 10 años y la duración de la aventura permanecen pendientes de medición.

La comprobación de identidad Android espera la ficha real de la aplicación, tolera dumps XML aún no disponibles durante el splash de Ajustes y conserva XML y captura como evidencia. Solo cierra el diálogo de bloqueo de Pixel Launcher en el emulador desechable. No omite el nombre, el arranque del juego, la auditoría de sprites ni los errores del juego. La emulación usa dos CPU, de acuerdo con las disponibles en el runner.
