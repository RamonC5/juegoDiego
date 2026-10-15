# Controles táctiles sin botones

Revisión del 15 de octubre de 2026, solicitada tras probar los botones del entrenamiento. La adaptación mantiene el control libre de Diego: avanzar, retroceder, detenerse y explorar los niveles rejugables.

## Referencias consultadas

| Juego | Evidencia consultada | Aplicación a Salto Heroes |
| --- | --- | --- |
| [Oddmar — soporte de Mobge](https://mobge.net/support/1/12/controls-controllers) | El desarrollador distingue los controles deslizantes y la alternativa de botones en ajustes. | Tomar los gestos y las zonas amplias como base. |
| [Leo’s Fortune — entrevista con sus desarrolladores](http://www.steveparis.net/2014/05/leos-fortune-interview-with-1337-senri.html) | La entrevista describe movimiento horizontal a la izquierda y movimiento vertical a la derecha; el programador explica el ajuste iterativo de respuesta e inercia. | Mantener movimiento libre, precisión horizontal y funciones independientes para cada dedo. |
| [Super Mario Run — Nintendo](https://supermariorun.com/en/) | Nintendo describe un personaje que corre constantemente y se controla con toques. | Referencia para una posible variante de avance automático; no se introduce ese cambio de movimiento en esta revisión. |

Esta distribución es una adaptación para las acciones existentes de Diego, no una reproducción exacta de otro juego. Los valores de sensibilidad requieren valoración jugando en los dispositivos físicos.

## Distribución inicial

| Zona | Gesto | Resultado |
| --- | --- | --- |
| Cualquier punto de la mitad izquierda | Apoyar y arrastrar ← / → | Eje de movimiento analógico. Poco recorrido camina; mucho recorrido corre. |
| Mitad de movimiento | Soltar | Detener la orden de movimiento y frenar. |
| Cualquier punto de la mitad derecha | Deslizar ↑ | Saltar en cuanto se supera el umbral, sin esperar a soltar. |
| Tras iniciar el salto | Mantener / soltar | Salto más alto / corto. Con salto completo activado basta el gesto. |
| Cualquier punto de la mitad derecha | Toque corto | Coger el objeto cercano o lanzar el que se lleva, una vez al soltar. |
| Botón Pausa | Pulsar | Abrir ajustes, liberar contactos y pausar la física. |

Se pueden intercambiar las mitades. La función queda fijada al apoyar cada dedo y se conserva al cruzar el centro. Los contactos de movimiento, salto y acción pueden coexistir. Un gesto de salto nunca produce también un lanzamiento al soltar. El pisotón sigue siendo aterrizar sobre un enemigo válido; no requiere otro gesto.

## Respuesta y ayuda

El eje horizontal parte del punto de apoyo. Tiene zona muerta, recorrido limitado y origen que sigue al dedo cuando se sobrepasa el recorrido. No hay botones ni palancas fijas. Solo se dibujan un trazo horizontal, una flecha de salto o un pequeño aro durante el contacto.

La guía textual dura diez segundos al entrar o cambiar los ajustes y se puede desactivar. Pausa permite cambiar el recorrido de los gestos, intercambiar lados, usar salto completo y decidir si los arrastres cortos también permiten correr. El ajuste anterior `button_scale` migra a `gesture_scale` si todavía no existe el nuevo valor. Las teclas y los eventos de mando se conservan.

Los contactos nuevos se procesan después de la interfaz. Los ya capturados se liberan aunque terminen fuera de la pantalla. Cancelar, pausar, cambiar de ventana o modificar los ajustes limpia las entradas pendientes. El ratón emulado desde un toque se ignora para evitar acciones duplicadas. Se emplean coordenadas del lienzo y umbrales proporcionales al área visible, con adaptación a la zona segura de Android.

## Comprobación

`tools/tests/test_player.gd` ejecuta 55 comprobaciones de comportamiento, incluidas las mecánicas previas y regresiones de gestos, simultaneidad, interfaz, tablet 4:3 y persistencia. La CI las ejecuta antes de exportar el APK.

`tools/tests/capture_player.gd` captura el entrenamiento, dos contactos activos, el menú y la proporción 4:3 mediante el renderizador real. Las capturas y el registro se encuentran en [la revisión de Diego](../art/characters/diego/qa.md).

Queda por comprobar la sensación del arrastre, el multitoque del hardware y el rendimiento en el móvil Android y la tablet Windows del usuario.
