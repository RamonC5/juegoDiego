# Controles táctiles sin botones

Revisión del 15 de octubre de 2026, solicitada tras probar los botones del entrenamiento. La adaptación mantiene el control libre de Diego: avanzar, retroceder, detenerse y explorar los niveles rejugables.

## Referencias consultadas

| Juego | Evidencia consultada | Aplicación a Super Diego |
| --- | --- | --- |
| [Oddmar — soporte de Mobge](https://mobge.net/support/1/12/controls-controllers) | El desarrollador distingue los controles deslizantes y la alternativa de botones en ajustes. | Tomar los gestos y las zonas amplias como base. |
| [Leo’s Fortune — entrevista con sus desarrolladores](http://www.steveparis.net/2014/05/leos-fortune-interview-with-1337-senri.html) | La entrevista describe movimiento horizontal a la izquierda y movimiento vertical a la derecha; el programador explica el ajuste iterativo de respuesta e inercia. | Mantener movimiento libre, precisión horizontal y funciones independientes para cada dedo. |
| [Super Mario Run — Nintendo](https://supermariorun.com/en/) | Nintendo describe un personaje que corre constantemente y se controla con toques. | Referencia para una posible variante de avance automático; no se introduce ese cambio de movimiento en esta revisión. |

Esta distribución es una adaptación para las acciones existentes de Diego, no una reproducción exacta de otro juego. Los valores de sensibilidad requieren valoración jugando en los dispositivos físicos.

## Distribución actual · doble salto (17 de octubre de 2026)

| Zona | Gesto | Resultado |
| --- | --- | --- |
| Cualquier punto libre de la mitad izquierda | Pulsar una vez | Primer salto inmediato y completo, sin mantener. |
| Mitad izquierda durante el vuelo | Pulsar otra vez | Un segundo impulso aéreo. No exige un intervalo de doble clic. |
| Mitad izquierda mientras está colgado | Pulsar | Soltarse con el impulso de la liana; queda un salto aéreo disponible. |
| Cualquier punto libre de la mitad derecha | Arrastrar ← / → | Movimiento analógico: poco recorrido camina; mucho recorrido corre. |
| Mitad derecha | Soltar el arrastre | Frenar. |
| Mitad derecha mientras está colgado | Arrastrar ↑ y mantener | Trepar por la liana. Volver al eje horizontal o soltar conserva la altura; se puede combinar con ← / → para balancearse. |
| Mitad derecha | Deslizar ↓ y mantener; después arrastrar ← / → | Agacharse y avanzar despacio con el mismo dedo. Soltar o deslizar arriba permite ponerse de pie, también debajo de una plataforma atravesable. Si el techo es sólido, un arrastre permite salir agachado. |
| Mitad derecha | Toque corto | Coger o lanzar, una vez al soltar; el lanzamiento funciona durante el ascenso y el descenso del salto. |
| Botón Pausa | Pulsar | Abrir ajustes y liberar contactos. |

Se pueden intercambiar las mitades. Cada contacto conserva su función al cruzar el centro. Un arrastre de movimiento o agacharse nunca dispara un salto o un lanzamiento. Se puede mover, saltar y actuar simultáneamente. Mantener el contacto de salto no repite impulsos; dos pulsaciones entre pasos físicos se conservan como dos órdenes. Se ignora el ratón emulado desde touch para evitar duplicados.

Hay un máximo de dos impulsos antes de aterrizar. Al salir andando de un borde queda un salto aéreo, además de la tolerancia inicial de borde. Aterrizar o agarrarse a una liana renueva la reserva; un pisotón deja un salto aéreo después del rebote. Agacharse tiene prioridad en el suelo y descarta saltos acumulados. Daño, pausa y reaparición limpian las órdenes que ya no corresponden. Teclado y mando usan dos pulsaciones de su botón de salto; conservan altura variable o el ajuste de salto completo.

## Respuesta y ayuda

Desde 0.12.0, lanzar durante el salto conserva el avance, el cambio de dirección y el segundo impulso disponible. La suelta sigue ocurriendo una sola vez en el fotograma 2. Mantener arriba solo trepa mientras Diego está sujeto a una liana; fuera de ella no salta ni lanza. En teclado se usa W / ↑ (reasignable) y en mando la cruceta o palanca izquierda hacia arriba. La trepa avanza a 160 px/s, se detiene antes del anclaje y respeta techos sólidos. Las manos siguen la altura elegida y el salto de salida conserva la velocidad tangencial correspondiente. No hay ascenso automático.

El eje horizontal parte del punto de apoyo. Tiene zona muerta, recorrido limitado y origen que sigue al dedo cuando se sobrepasa el recorrido. No hay botones ni palancas fijas. Solo se dibujan un trazo horizontal, una flecha de salto o agacharse o un pequeño aro durante el contacto.

El escenario conserva las guías superpuestas ocultas; las instrucciones y los nombres accesibles están disponibles en pausa. Pausa permite cambiar el recorrido de los gestos, intercambiar lados, usar salto completo en teclado/mando y decidir si los arrastres cortos también permiten correr. El ajuste anterior `button_scale` migra a `gesture_scale` si todavía no existe el nuevo valor. Las teclas y los eventos de mando se conservan.

Los contactos nuevos se procesan después de la interfaz. Los ya capturados se liberan aunque terminen fuera de la pantalla. Cancelar, pausar, cambiar de ventana o modificar los ajustes limpia las entradas pendientes. El ratón emulado desde un toque se ignora para evitar acciones duplicadas. Se emplean coordenadas del lienzo y umbrales proporcionales al área visible, con adaptación a la zona segura de Android.

## Comprobación

`tools/tests/test_player.gd` comprueba el comportamiento, incluidas las mecánicas previas y regresiones de gestos, simultaneidad, interfaz, tablet 4:3 y persistencia. La CI las ejecuta antes de exportar el APK. `test_player_movement.gd` añade 30 comprobaciones de doble salto, límite de impulsos, caída, daño, reaparición, pausa y agarre visual durante dos ciclos.

`tools/tests/capture_player.gd` captura el entrenamiento, dos contactos activos, el menú y la proporción 4:3 mediante el renderizador real. Las capturas y el registro se encuentran en [la revisión de Diego](../art/characters/diego/qa.md).

Queda por comprobar la sensación del arrastre, el multitoque del hardware y el rendimiento en el móvil Android y la tablet Windows del usuario.



