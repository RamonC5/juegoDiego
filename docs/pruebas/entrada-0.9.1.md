# Entrada animada y título · 0.9.1

La entrada conserva el acceso inmediato a «Jugar ahora», los ocho mundos y el bloqueo de todos salvo Bosque Esmeralda.

## Movimiento

`AdventureIntro` compone acciones con los SpriteFrames originales de Diego. La costa y el cielo encadenan carrera, impulso, caída y apoyo; las cuevas preparan y sueltan la vasija, y el volcán termina con una celebración. Los ciclos de carrera conservan sus fotogramas reales de brazos y piernas. No se han generado hojas nuevas ni se han cambiado los movimientos del jugador durante la partida.

El reloj del menú controla los fotogramas y un fundido corto entre poses consecutivas. La raíz avanza de forma continua y el aterrizaje incorpora una compresión del 6 %. La liana realiza un balanceo sinusoidal de 0,62 radianes con pivote en las manos. La vasija sigue una trayectoria independiente desde el instante de suelta y desaparece al terminar, sin volver a la mano.

Las viñetas duran 3,2 s y se enlazan con un fundido de 0,30 s. El actor se desvanece durante 0,16 s en los extremos para ocultar su recolocación entre aventuras. Un acercamiento del 2,5 % añade profundidad al fondo. El shader del montaje conserva el tinte y la opacidad de CanvasItem; el shader de los personajes de la partida permanece separado.

## Identidad y accesibilidad

`SuperheroTitle` dibuja «SUPER DIEGO» con la fuente integrada de Godot: peso aumentado, inclinación, contorno azul oscuro, filo crema y relieve coral sobre un emblema azul con rayos dorados. No requiere fuentes instaladas en Android o Windows. Realiza una entrada suave de 0,72 s, sin parpadeo permanente. Conserva el nombre accesible «Super Diego».

«Movimiento reducido» presenta un fotograma estable y detiene sprite, fundidos, zoom, vasija, cuerda y entrada del título. «Repetir aventuras» reinicia ambos relojes. Los botones conservan foco visible y nombres accesibles; el mapa mantiene su encabezado de texto.

## Validación

- Godot 4.7.2, ejecución headless con los recursos reales del APK 0.9.0 y los scripts modificados: **3154 comprobaciones, 0 fallos**.
- La regresión recorre dos vueltas completas a 60 Hz, verifica cambios de fotogramas y acciones, continuidad de la raíz, fundido de mundos, limpieza de la vasija, movimiento reducido y navegación de entrada → mapa → bosque → pausa → mapa → inicio.
- `capture_entrance.gd` añade secuencias de doce imágenes para carrera, salto, lanzamiento, liana y doble salto, además de los ocho mundos y las vistas móvil/tablet.
- La importación completa, las capturas Compatibility y el APK se comprueban en CI. La fluidez percibida y el rendimiento en un móvil o tablet físicos requieren revisión en esos dispositivos.
