# Colección, vestuario y Luci · Super Diego 0.8.0

Las hojas ahora desbloquean prendas permanentes sin gastarse. Los cristales forman parte de la colección del bosque y tres fragmentos opcionales despiertan a Luci, una luciérnaga acompañante. La salida sigue requiriendo únicamente las tres llaves del intento.

| Hito | Recompensa | Apariencia |
| --- | --- | --- |
| Inicio | Aventurero | Vestuario original de Diego |
| 12 hojas | Pañuelo de otoño | Pañuelo rojo |
| 45 hojas | Chaleco de hojas | Helechos raster sobre el chaleco, pañuelo ámbar |
| 100 hojas | Explorador del bosque | Helechos, pañuelo verde y pantalón de explorador |
| Todas las hojas, cristales y fragmentos del bosque | Guardián dorado | Acabado dorado del equipo del bosque |
| Tres fragmentos de luz | Luci | Ayudante opcional permanente |

Los hitos son un primer balance de autoría; los tiempos hasta cada recompensa requieren observación jugando. La duración y el recorrido principal del bosque permanecen en su presupuesto anterior de 9,2–10,94 minutos estimados. Los objetos arrojadizos siguen resolviendo dianas y combates; la ropa no consume sus herramientas ni altera velocidad, colisión, saltos o agarres.

## Cómo se usa

El icono de camiseta del HUD muestra el avance hacia la siguiente prenda. Se puede abrir también **Pausa → Colección**. El vestuario pausa la partida, presenta a Diego con la prenda seleccionada, permite probar visualmente incluso las pendientes y ofrece **Equipar** al desbloquearlas. Los botones distinguen bloqueado, disponible y equipado mediante texto y estado, además de color. Escape/Start vuelve primero a pausa; Continuar limpia los gestos anteriores.

La primera prenda y los siguientes desbloqueos muestran una confirmación breve con acceso al vestuario; abrirlo siempre es voluntario. Las recompensas no se equipan automáticamente ni se gastan las hojas. El menú permite dejar descansar al ayudante, con preferencia guardada.

## Fragmentos y ayudante

| ID estable | Lugar | Posición |
| --- | --- | --- |
| `clear` | Repisa del primer claro | (1175, 390) |
| `grove` | Interior de la gruta bajo las hojas | (11025, 1026) |
| `vines` | Barranco de las lianas | (26680, 470) |

Luci duerme en una planta del primer claro, en (480, 565). Al reunir los tres fragmentos aparece junto a Diego. Acompaña su marcha, celebra llaves y dobles saltos, y se coloca fuera de su cuerpo y del área de aterrizaje. Sus alas usan cuatro poses de un raster original; no se simulan moviendo solo la imagen completa.

Al acercarse a la trampilla secreta, se aproxima suavemente hacia ella y muestra un resplandor lento. Reconoce la visita al subsuelo durante el intento y deja de señalar esa entrada. Recoge únicamente hojas a un máximo de 68 px del centro del cuerpo, una por comprobación cada 0,25 s, con un rayo contra el entorno para impedir recogidas a través de paredes. No recoge fragmentos, cristales ni llaves a distancia. El ciclo se detiene en pausa y derrota; al reaparecer vuelve junto al jugador.

## Guardado y recuperación

`CollectionProgress` guarda inmediatamente cada recogida aceptada en `user://collection.json`, esquema 1, usando un temporal, comprobación de escritura y renombrado. Conserva una copia `.bak` del último archivo válido. La carga valida la estructura, usa la copia ante corrupción y acepta una instalación sin archivo. Un fallo de escritura revierte la operación, mantiene el objeto disponible y presenta un aviso; no concede una recompensa sin guardar.

Cada hoja y cristal tiene un ID de nivel, tipo y coordenadas de autoría. Los fragmentos tienen ID propio independiente de su posición. El manifiesto del nivel valida el ID y tipo antes de aceptar la recogida. No se crean hojas ni fragmentos adicionales al morir, reiniciar o cerrar. Al rejugar se muestran solo los coleccionables todavía pendientes y los contadores reflejan la colección permanente.

El perfil es independiente de `progress.json` (mejores resultados), `controls.cfg` y del estado espacial del farol. Morir conserva la colección mientras el tramo posterior del nivel se rearma. Cerrar o reiniciar conserva ropa, colección y ayudante; las llaves y mecanismos vuelven a su estado inicial del intento. No se ha añadido guardado de posición o de un intento a mitad del nivel. Los resultados antiguos se conservan y no se convierten en hojas, porque no identifican cuáles se recogieron.

## Implementación y evidencia

- Núcleo: `CollectionRewards` y `CollectionProgress`, compuestos por `boot/main.gd` e inyectados explícitamente en `ForestStage`, sin autoload.
- Datos: posiciones e IDs opcionales en `ForestLevelDefinition` y el generador reproducible del bosque.
- Dibujo: `PlayerWardrobe` aplica material propio por instancia sobre todas las animaciones de Diego; no sustituye sus poses ni sus sensores.
- UI: `CollectionMenu`, scroll con seguimiento de foco, estados escritos, acciones de al menos 48 px, tema con foco y adaptación a zona segura.
- Regresión: `tools/tests/test_collection_rewards.gd`; capturas Compatibility: `tools/tests/capture_collection.gd`.
- [Ficha de la dinámica](dinamicas/coleccion_bosque.json) · [Personaje y recursos](../art/characters/luci/ficha.md).

Las pruebas automatizadas se registran en [la evidencia de 0.8.0](pruebas/coleccion-0.8.0.md). Android y tablet Windows físicos, tacto, descubrimiento, diversión, accesibilidad con lector y rendimiento del perfil real quedan pendientes.
