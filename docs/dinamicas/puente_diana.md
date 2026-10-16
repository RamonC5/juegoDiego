# El puente de raíces · nivel 1 del Bosque Esmeralda

Diego recoge una piña, la lanza a una diana de madera y despliega un puente. Aprende la relación en una pasarela de ensayo y la repite para alcanzar la **segunda llave de ramas**. La dinámica está integrada en el nivel actual desde la versión **0.3.0**.

| Dato | Estado |
| --- | --- |
| Nivel | `world_01_level_01` · El despertar del bosque |
| Base | `main`, commit `11b12f2bd35ad1c068c41be50d5d85082a16ccef` |
| Integración | Dos estaciones, piñas recuperables, suelo de recuperación y tres faroles |
| Evidencia | 55 comprobaciones de puentes; 264 en las cuatro suites |
| Ficha verificable | [puente_diana.json](puente_diana.json) |

## Recorrido integrado

| Estación | Coordenadas lógicas | Experiencia |
| --- | --- | --- |
| Ensayo | Piña `(2540, 574)`, diana `(2780, 530)`, pasarela de x=2850 a 3270 | Lanzamiento desde tierra firme, apertura y cruce. Farol previo en x=2470. |
| Recuperación | Suelo y=820; apoyos y=740 y y=660 junto a la orilla izquierda | Caminar hacia los apoyos y saltar de vuelta al puesto. La cámara acompaña el descenso. |
| Puente principal | Piña `(3430, 574)`, diana `(3710, 530)`, puente de x=3790 a 4270 | Repetir el lanzamiento tras el farol de x=3390. Cámara con anticipación suave para ver diana y llegada. |
| Recompensa | Llave 2 `(4560, 466)`, plataforma y=515 y farol posterior en x=4820 | Cruzar, saltar a la llave y continuar. Una patrulla queda después del puente y otra protege el cristal alto opcional. |

Las dianas fijas tienen una recepción circular de radio 58 y una imagen de 136 unidades. La apertura dura 0,6 segundos; habilita el suelo al terminar y el puente permanece estático al cruzarlo. Los saltos de carrera y salto completo se han probado contra ambos pasos cerrados: no sustituyen su activación. Los tres huecos pequeños restantes mantienen el salto normal.

Las tres llaves conservan recogida automática y manos libres. Su orden es libre; la ranura visible 2 corresponde al índice interno 1. La puerta exige las tres y los secretos siguen siendo opcionales. Los puentes abiertos permiten volver a objetivos pendientes.

## Controles y accesibilidad

| Medio | Acción |
| --- | --- |
| Android y Windows táctil | Arrastrar para situarse y mirar a la diana, soltar para frenar. Toque corto para coger y otro para lanzar en la zona de acción. Deslizar arriba para saltar después. |
| Teclado | A/D o flechas, E para coger/lanzar, Espacio para saltar; acciones reasignables. |
| Mando | Eje o cruceta, `grab_throw` y `jump` mediante el mapa existente. |

No se añade un gesto de apuntado. La acción depende de las manos; tocar la diana no la activa. Agacharse bloquea recoger/lanzar según sus reglas actuales: ambos puestos permiten estar erguido.

Anillos de madera, raíz de conexión, rótulos de ENSAYO/PUENTE y marca de acierto comunican el estado sin depender del color ni del sonido. Las pistas aparecen al entrar, fallar o abrir; «Puente abierto» se anuncia al habilitar su colisión. Se conservan lados intercambiables, sensibilidad, salto completo, carrera opcional, reasignación y foco visible, sin destellos ni sacudidas. El audio, lector de pantalla y escalado avanzado de texto siguen pendientes.

## Recuperación y persistencia

| Situación | Comportamiento implementado |
| --- | --- |
| Impacto válido | Activa una sola vez la diana asociada. Cualquier arrojadizo válido sirve, incluido un barril; cada estación garantiza su piña. |
| Objeto sostenido, apoyado o sin ataque válido | La diana continúa pendiente. |
| Piña fallada o soltada por daño | Recuperable; regresa al puesto a los cuatro segundos, sin crear otra instancia. |
| Piña fuera del área local | Vuelve a su puesto. Sostenerla cancela la reposición. |
| Caída o muerte | Conserva llaves y activaciones del intento. Un despliegue interrumpido se restaura abierto al reaparecer. |
| Pausa o pérdida de foco | Congela apertura, reposición y reloj; libera los contactos de control. |
| Volver a un farol anterior | Mantiene la reaparición más avanzada. |
| Reiniciar o rejugar | Cierra ambos puentes y repone dianas, piñas y las tres llaves; conserva mejores resultados y desbloqueos. |
| Cerrar la aplicación | Pierde el intento actual; conserva resultados completados y ajustes. No hay guardado a mitad de nivel. |

## Integración y arte

[RootBridgeDefinition](../../game/features/levels/mechanisms/root_bridge_definition.gd) contiene datos por estación; [ForestThrowTarget](../../game/features/levels/mechanisms/throw_target.gd) valida impactos y emite una activación; [RootBridge](../../game/features/levels/mechanisms/root_bridge.gd) administra apertura y colisión. [ForestStage](../../game/features/levels/forest_stage.gd) compone referencias explícitas, conserva activaciones y gestiona los faroles. [level_01.tres](../../game/data/worlds/world_01/level_01.tres) define terreno, puestos y recompensa.

La diana usa la capa de interacción consultada por los arrojadizos; el cuerpo de Diego la atraviesa. El puente usa la capa de entorno. No se añade bus global ni autoload.

Los PNG RGBA `root_bridge_v001.png` y `throw_target_v001.png` están en `game/assets/textures/environments/bosque_esmeralda/mechanisms/`. La herramienta integrada de imágenes los generó tomando el atlas del bosque como referencia; Godot limita su importación a 1024 y 256 píxeles respectivamente. [Prompts exactos y metadatos](../../art/levels/bosque_esmeralda/bridge-prompts.md). El recorte del puente conserva el PNG original.

El puesto genérico de x=5370 sigue teniendo una vasija y su pista ya la identifica correctamente. Las dos piñas nuevas proceden de las estaciones y usan el índice 2 del catálogo.

## Verificación y límites

```sh
godot --headless --fixed-fps 60 --path . --script tools/tests/test_bridges.gd
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py docs/dinamicas/puente_diana.json
```

Las cuatro suites suman **264 comprobaciones correctas**: 88 del protagonista, 63 de objetos, 58 del bosque y 55 de puentes. [Registro de puentes](../../art/levels/bosque_esmeralda/qa-bridge-tests.txt). Cubren impactos físicos, gesto táctil normal e intercambiado, teclado, barril alternativo, pérdida y daño llevando piñas, ausencia de duplicados, recuperación por los apoyos, salto directo bloqueado, pausa, reaparición y reinicio.

La suite termina una partida completa resolviendo ambos mecanismos y consiguiendo las tres llaves sin teletransportes durante ese recorrido. Los casos aislados sí sitúan al jugador en posiciones de preparación. La CI repite las suites y captura móvil, tablet y panorámico antes de exportar el APK.

**Duración pendiente de medir:** los 4–5 minutos de la propuesta son un presupuesto de autoría, no una medición con un niño. Esta integración amplía el prototipo actual; llegar al mínimo de 15 minutos de la aventura completa requiere más contenido y primeras partidas observadas. No se bloquea la salida por reloj. Quedan pendientes instalación, tacto y 60 FPS en Android y Windows físicos.
