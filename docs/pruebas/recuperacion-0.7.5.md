# Plataformas reales y restauración por farol · 0.7.5

Solicitud del 18 de octubre de 2026. Base publicada: `0b732033f5e97e7dd1832d2d08771e8b43b42e24` (0.7.4).

## Reproducción y alcance

Se reprodujo el bloqueo de postura sin mover ni sustituir la primera plataforma del bosque: Diego en (740, 600), repisa atravesable desde abajo en y=515. Tras agacharse y soltar abajo permanecía agachado porque `intersect_shape` también devolvía esa superficie unilateral. La prueba anterior usaba un techo sólido y solo acreditaba salir agachado; no cubría ponerse de pie debajo de una plataforma real.

La comprobación actual inspecciona las formas y permite incorporar el cuerpo debajo de superficies unilaterales. Mantiene el suelo, el salto y el aterrizaje encima. Un techo sólido continúa bloqueando la cápsula completa y permite salir agachado. La entrada táctil admite alternar abajo y arriba con el mismo contacto, sin pedir saltos ni lanzamientos.

El retorno ordinario por los nueve portones con farol posterior pasó en el recorrido automatizado de la base 0.7.4; no se ha reproducido localmente la secuencia exacta que cerró el portón en el dispositivo del usuario. Para cubrir ese estado, la regresión introduce expresamente una pérdida del estado transitorio de un portón ya consolidado. En 0.7.4 se quedaba cerrado con sus dianas rotas al otro lado, porque omitir un reinicio no reconstruía su estado físico. La nueva copia del farol restaura marcas, dibujo y colisión, además de dianas y puentes. Lo posterior sigue reiniciándose como un puzzle completo.

## Evidencia automatizada

Godot 4.7.2, física a 60 pasos por segundo. Las suites existentes y la nueva regresión suman **910 comprobaciones, 0 fallos**, además del arranque y cinco comprobaciones Python de la validación Android. Los recursos importados para la ejecución local proceden del APK validado anterior; la CI vuelve a importar el arte fuente.

`test_real_recovery.gd` contiene 55 comprobaciones: plataforma real, contactos táctiles, alternancia abajo/arriba, techo sólido simultáneo, salida, salto y apoyo sobre la repisa, y avance/muerte/menú/reaparición/retorno físico por los nueve portones anteriores a faroles. Comprueba también que el portón siguiente vuelve a estar cerrado y que un farol avanzado conserva las aperturas más antiguas. La misma prueba falla sobre 0.7.4 y pasa con la corrección; la desincronización de portón se identifica como inyección de fallo, no como reproducción de su causa original.

`capture_forest.gd` produce `preview_crouch_under_platform.png` y `preview_stand_under_platform.png` con la misma plataforma y posición. `test_android_apk.py` llega andando mediante gestos reales y exige en el registro del APK una transición agachado/de pie entre x=670 y x=876, a y=600 y sin salir de la repisa. Si queda agachado, está encima o se incorpora tras salir de la plataforma, la prueba falla. La auditoría conserva la versión instalada y la evidencia. Esta prueba se ejecuta en emulador; tacto y rendimiento en el móvil y la tablet Windows físicos quedan pendientes.
