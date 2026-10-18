# Colección, vestuario y Luci · Super Diego 0.10.0

Las hojas ahora desbloquean prendas permanentes sin gastarse. Los cristales forman parte de la colección del bosque y tres fragmentos opcionales despiertan a Luci, una luciérnaga acompañante. La salida sigue requiriendo únicamente las tres llaves del intento.

| Hito | Recompensa | Apariencia |
| --- | --- | --- |
| Inicio | Aventurero | Vestuario original de Diego |
| 12 hojas | Pañuelo de otoño | Pañuelo coral intenso |
| 45 hojas | Chaleco de hojas | Chaleco esmeralda con trama textil y pañuelo lima |
| 100 hojas | Explorador del bosque | Chaleco azul glaciar, pañuelo turquesa y pantalón azul noche |
| Todas las hojas, cristales y fragmentos del bosque | Guardián dorado | Equipo dorado y pañuelo marfil |
| Tres fragmentos de luz | Luci | Ayudante opcional permanente |

Los hitos son un primer balance de autoría; los tiempos hasta cada recompensa requieren observación jugando. La duración y el recorrido principal del bosque permanecen en su presupuesto anterior de 9,2–10,94 minutos estimados. Los objetos arrojadizos siguen resolviendo dianas y combates; la ropa no consume sus herramientas ni altera velocidad, colisión, saltos o agarres.

## Cómo se usa

El icono de camiseta del HUD muestra cuántas equipaciones tienes (por ejemplo, 2/5); su detalle indica la prenda equipada y la próxima meta. Se puede abrir también **Pausa → Colección**. El vestuario pausa la partida, presenta a Diego con la prenda seleccionada, permite probar visualmente incluso las pendientes y ofrece **Equipar** al desbloquearlas. Los botones distinguen bloqueado, disponible y equipado mediante texto y estado, además de color. Volver permanece en la cabecera y regresa a pausa. Seguir jugando cierra directamente el vestuario y limpia los gestos; en derrota permite volver al farol y al completar el nivel queda desactivado. Escape/Start y Atrás de Android vuelven primero a pausa. El catálogo se desplaza de forma independiente, sin empujar la salida fuera de pantalla.

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
- Dibujo: `PlayerWardrobe` aplica material propio por instancia sobre todas las animaciones de Diego. Las paletas del catálogo se comparten con miniaturas y vista previa, y las máscaras abarcan luces y sombras. No sustituye poses ni sensores.
- UI: `CollectionMenu`, scroll con seguimiento de foco, estados escritos, acciones de al menos 48 px, tema con foco y adaptación a zona segura.
- Regresión: `tools/tests/test_collection_rewards.gd`; capturas Compatibility: `tools/tests/capture_collection.gd`.
- [Ficha de la dinámica](dinamicas/coleccion_bosque.json) · [Personaje y recursos](../art/characters/luci/ficha.md).

Las pruebas automatizadas se registran en [la evidencia de 0.8.0](pruebas/coleccion-0.8.0.md). Android y tablet Windows físicos, tacto, descubrimiento, diversión, accesibilidad con lector y rendimiento del perfil real quedan pendientes.


## Presentación moderna y navegación · 0.10.0

Tarjetas azul noche con miniaturas reales, progreso, estados escritos y acento por recompensa. La vista de Diego indica claramente si está equipado, disponible o en prueba bloqueada. El equipo original y los IDs del guardado se conservan; las recompensas desbloqueadas se equipan voluntariamente.

La cabecera fija corrige el desbordamiento anterior: el mínimo del listado no aumenta la altura del panel. Las máscaras de ropa se amplían a tonos medios y sombras y la paleta se declara en cada recompensa, sin depender del orden del catálogo. Es una revisión de materiales sobre los sprites existentes, no una sustitución de sus siluetas.

`test_reward_presentation.gd` comprueba clics/toques reales, salida, bloqueo y equipamiento en 1280×720, 960×540 y 1024×768, además de Atrás Android, guardado y fin del nivel. `capture_collection.gd` produce capturas del original y cada prenda más los tres tamaños de vestuario. El skill [crear-recompensas-super-diego](../.agents/skills/crear-recompensas-super-diego/SKILL.md) define diseño, integración, compatibilidad y verificación para futuras prendas.
