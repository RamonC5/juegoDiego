# El puente de raíces · primera dinámica del Bosque Esmeralda

Diego recoge una piña, la lanza a una diana de madera y despliega un puente de raíces. Aprende la relación en una pasarela segura y la aplica después para alcanzar la **segunda llave de ramas** del nivel 1. La satisfacción principal es ver cómo su lanzamiento transforma el camino.

| Dato | Diseño |
| --- | --- |
| Nivel | `world_01_level_01` · El despertar del bosque |
| Dinámica | `puente_diana`, primera dinámica nueva de la ampliación |
| Público | Niño de 10 años |
| Estado | Propuesta documentada; integración y pruebas jugables pendientes |
| Recompensa | Llave visible 2 de 3, recogida automáticamente |
| Duración | 4–5 minutos estimados para este bloque completo |
| Ficha verificable | [puente_diana.json](puente_diana.json) |
| Base revisada | `RamonC5/juegoDiego`, `main`, commit `dd5d7891fa421a6c23befe1479421ed38e942f2d`, 16 de octubre de 2026 |

## Encaje en el nivel 1

Es la primera mecánica nueva prevista para el bosque ampliado. Antes se practican movimiento, plataformas, pisotón y la ruta de la primera llave. El puente da acceso a la llave 2; la última parte combina las acciones conocidas para conseguir la llave 3. El orden de recogida es libre: la numeración identifica la llave y no exige conseguir antes la ranura anterior.

La salida continúa exigiendo las tres llaves. Hojas, cristales y retos de maestría son opcionales. El bloque de 4–5 minutos se incluye una sola vez en el futuro recorrido de 18–22 minutos estimados de la aventura. El requisito de al menos 15 minutos corresponde al nivel completo y necesita medición con el público objetivo; el prototipo actual no acredita ese tiempo.

## Recorrido del jugador

Las dos estaciones reutilizan la misma relación: **lanzamiento → diana → puente**. Solo aumenta la distancia y se combina después con habilidades conocidas.

| Fase | Qué hace Diego y qué descubre | Presupuesto exclusivo |
| --- | --- | --- |
| 1. Leer el mecanismo | Ve una piña en su puesto, una diana con anillos y una raíz que conecta la diana con la pasarela recogida. Todo cabe en una vista estable sobre suelo seguro. | 0,5–0,75 min |
| 2. Ensayar con seguridad | Recoge la piña y acierta a una diana grande y quieta. Se despliega una pasarela baja que da acceso al tramo siguiente. Un suelo inferior permite recuperarse al caer. | 1–1,25 min |
| 3. Abrir el puente principal | Activa el farol previo, encuentra otra piña y repite el lanzamiento desde tierra firme, a una distancia algo mayor. La diana y el destino se ven antes de actuar. | 1,25–1,5 min |
| 4. Alcanzar la recompensa | Cruza el puente ya abierto, supera una patrulla de Terrón mediante pisotón o lanzamiento y dos apoyos anchos. Toca la llave 2 y llega al farol siguiente, con ruta de vuelta. | 1,25–1,5 min |

La suma es **4–5 minutos estimados**, sin tiempos adicionales por la ficha de la dinámica. No se presuponen fallos para alcanzar el presupuesto. La apertura dura aproximadamente 0,6 segundos; no hay cuenta atrás ni espera para permitir pasar. Si las pruebas resultan más cortas, se registra la duración y se ajusta el contenido del nivel completo.

La patrulla aparece después del puente y fuera de la posición de lanzamiento. Así el niño aprende primero la causa y su efecto, y combina después acciones que ya conoce. El enemigo conserva su vulnerabilidad al pisotón.

## Controles y señales

| Medio | Acción |
| --- | --- |
| Android y Windows táctil | Arrastrar en la zona de movimiento para acercarse y mirar hacia la diana; soltar para frenar. Un toque corto en la zona de acción recoge la piña y otro la lanza. Deslizar arriba permite saltar en el recorrido posterior. |
| Teclado | A/D o flechas para moverse, E para coger/lanzar y Espacio para saltar; acciones reasignables. |
| Mando | Eje o cruceta para moverse; acciones existentes `grab_throw` y `jump`. Las indicaciones no presuponen las mismas letras en todos los mandos. |

El lanzamiento sigue la dirección de Diego. No hay apuntado libre, gesto de arrastrar una trayectoria ni interacción al tocar la diana. Coger y lanzar usan el mismo gesto según si las manos están vacías u ocupadas; la diana responde únicamente a un impacto. Agacharse bloquea el lanzamiento en el código actual: la situación se resuelve erguido, con espacio suficiente.

Las pistas cambian por eventos, sin obligar a esperar:

- Junto al puesto, con las manos vacías: «Toca para coger la piña».
- Con la piña: «Mira a la diana y toca para lanzar».
- Tras un fallo: «Acércate, mira a la diana y vuelve a lanzar».
- Al quedar transitable: «Puente abierto».
- Al recoger la llave: «Llave de ramas 2 · X / 3», usando el contador real.

La diana tiene anillos, se hunde al acertar y conserva una marca visible. Una raíz muestra la conexión con su puente. Todo debe entenderse con el sonido silenciado; el proyecto aún no tiene audio. Los futuros sonidos de golpe y crujido serán complementarios. Textos contrastados, zona segura y una composición alejada de los pulgares deben comprobarse en móvil y tablet. Se conservan sensibilidad, lados intercambiables, salto completo, carrera opcional, reasignación y foco visible, sin destellos ni sacudidas.

## Geometría y aspecto

Usar raíces entrelazadas con musgo, madera y sombreado suave, coherentes con el arte raster 2D HD del bosque existente. La diana es un mecanismo del escenario; no representa un enemigo nuevo. Los recursos de diana y puente, recogido y desplegado, quedan pendientes de producción.

Para el primer blockout se propone una recepción de 128 × 128 unidades lógicas, alineada aproximadamente con la altura de suelta de la mano. La separación desde la mano hasta la diana comienza en 180–240 unidades en el ensayo y 240–300 en el puente principal. Son valores iniciales, no distancias físicas verificadas. La piña actual tiene trayectoria corta y poco elevada: situar una diana muy por encima de la mano obligaría a rediseñar el lanzamiento.

Mantener al jugador fuera del volumen que aparecerá al desplegar el puente. Habilitar la colisión al terminar la apertura y entonces anunciar el paso. El puente queda estático mientras Diego lo cruza: esta dinámica no añade transporte sobre plataformas móviles.

El trazado debe hacer necesario el mecanismo sin pedir un salto de precisión. Comprobar con movimiento real, salto completo, carrera y rebote que no se pueda eludir por encima o desde una plataforma vecina. Bajo el ensayo hay recuperación; en el puente principal se muestran borde y llegada, con regreso accesible desde ambas orillas. La anchura final y las coordenadas de la llave se fijarán al verificar el recorrido.

## Reglas y recuperación

| Situación | Resultado previsto |
| --- | --- |
| Impacto lanzado válido | Activa una sola vez la diana y su puente. Cualquier arrojadizo válido sirve; la piña está garantizada en el puesto. |
| Objeto sostenido, apoyado, demasiado lento o pisotón | La diana sigue pendiente. |
| Segundo impacto o señal duplicada | No vuelve a desplegar ni duplica la recompensa. |
| Piña fallada o perdida | Se puede recuperar; al asentarse vuelve a su puesto tras 4 segundos. Si sale del área local, regresa. Cada puesto conserva una sola instancia. |
| Piña sostenida | La reposición se cancela para impedir duplicados. |
| Caída o muerte | Las llaves y activaciones resueltas se conservan durante el intento; reaparece en el último farol. |
| Muerte durante el despliegue | El puente activado se restaura abierto antes de habilitar al jugador. |
| Pausa o pérdida de foco | Se detienen despliegue, pistas y reposición; reanudar no dispara una acción retenida. |
| Regreso para buscar una llave | Puentes abiertos y caminos de vuelta siguen disponibles. |
| Reiniciar o rejugar | Se cierran los dos puentes y se reponen dianas, piñas y las tres llaves. Se conservan desbloqueos y mejores resultados. |
| Cerrar realmente la aplicación | Con el guardado actual se pierde el intento; permanecen los resultados ya completados y los ajustes. |

Conservar aperturas al morir es trabajo nuevo. El guardado de un intento para continuar otro día es una mejora separada y pendiente. No debe anunciarse como disponible con esta dinámica.

Se proponen dos puntos seguros para este bloque: uno tras el ensayo, inmediatamente antes del puente principal, y otro después de la llave. Entre ellos se presupuestan como máximo 3 minutos. Hay que revisar también la llegada al primer farol para mantener el criterio de aproximadamente 3–4 minutos del nivel completo.

## Inventario contrastado y trabajo de integración

La lectura del código confirma estas diferencias respecto al diseño:

| Capacidad actual | Aplicación y trabajo pendiente |
| --- | --- |
| Diego ya recoge y lanza según `grab_throw`; agacharse lo detiene. | Reutilizar acciones, animaciones y dirección. El reto no exige lanzar agachado ni crear un gesto de apuntado. |
| `ThrowableObject` valida lanzamientos, repone objetos y recupera los que salen de sus límites. `ForestStage` ya configura 4 segundos de reposición. | Configurar puestos locales de piñas y límites de recuperación; comprobar daño, caída y objetos sostenidos sin duplicación. |
| `pina_bosque` existe y ocupa el índice 2 del catálogo. Los puestos del bosque usan 0, 1, 0, 3 y 0. | Añadir el índice 2 donde lo requiera el recorrido. La pista actual de piña en x=5350 corresponde a una vasija de índice 3; corregir su correspondencia durante la integración. |
| Hay una diana de entrenamiento con `receive_thrown_hit` y `completed`. | Crear un mecanismo reutilizable de diana y puente, con dos instancias y activación independiente. La diana de entrenamiento no abre puentes. |
| Las llaves son automáticas y se conservan al reaparecer. | Reubicar la segunda llave tras el recorrido del puente, conservar su índice interno 1 y verificar vuelta y salida. |
| El bosque tiene un único farol y un booleano de activación. | Generalizar datos y estado para varios faroles; conservar mecanismos resueltos durante el intento. |
| `LevelProgress` guarda resultados al completar. | Mantener ese comportamiento declarado. El guardado de intentos necesita un sistema adicional. |

La integración debe usar componentes y referencias explícitas conforme a la [arquitectura](../ARQUITECTURA.md). Las rutas siguientes son propuestas de trabajo:

| Pieza | Responsabilidad propuesta |
| --- | --- |
| `game/features/levels/mechanisms/throw_target.gd` | Recibir y validar impactos; emitir `activated(mechanism_id)` una sola vez. |
| `game/features/levels/mechanisms/root_bridge.gd` | Gestionar cerrado, desplegando y abierto; mantener dibujo y colisión coherentes. |
| `ForestLevelDefinition` y `level_01.tres` | Datos de las dos estaciones, piñas, terreno, faroles y recompensa. |
| `ForestStage` | Componer referencias, recibir activaciones y conservar sus identificadores durante el intento. |
| `boot` y HUD | Presentar pistas y contador mediante las señales existentes. |

El puente pertenece a la capa de entorno. La diana debe estar en una capa ya consultada por los arrojadizos y exponer el contrato de impacto. No necesita bus global, autoload ni lógica de desbloqueo en la interfaz.

## Criterios de aceptación

La [ficha JSON](puente_diana.json) contiene la matriz funcional y las sesiones de juego pendientes. Antes de marcarla implementada hay que comprobar:

1. Un impacto válido activa solo su puente; impactos inválidos y duplicados no lo alteran.
2. Fallar, perder la piña, recibir daño y morir dejan una solución disponible, sin objetos ni llaves duplicados.
3. Pausar y morir durante la apertura mantienen un estado seguro; volver al farol conserva puentes y llaves resueltos.
4. La llave visible 2 funciona incluso si faltan las otras dos; la puerta exige las tres y finaliza una sola vez.
5. La ruta permite volver a cualquier llave pendiente y no eludir el mecanismo con las capacidades reales de Diego.
6. Un niño que juega por primera vez comprende la relación con las pistas breves. Se registran tiempos y ayudas de forma anónima, separando secretos, pausas y repeticiones por derrota.
7. Android y Windows táctiles ofrecen lectura y control adecuados; se revisan también teclado, mando, pausa y rendimiento en dispositivos físicos.

La validación del JSON comprueba consistencia documental. La física, diversión, duración real y comportamiento en dispositivos requieren la integración y las pruebas anteriores.

## Fuentes

La ficha identifica el commit y las observaciones de cada fuente. Archivos principales de la revisión:

- [Datos actuales del nivel](../../game/data/worlds/world_01/level_01.tres).
- [Construcción y recuperación del bosque](../../game/features/levels/forest_stage.gd).
- [Movimiento e interacción de Diego](../../game/features/player/diego.gd).
- [Objeto arrojadizo y recuperación](../../game/features/objects/throwable_object.gd).
- [Piña del bosque](../../game/features/objects/definitions/pina_bosque.tres) y [catálogo de objetos](../../game/features/objects/throwable_catalog.gd).
- [Diana de entrenamiento](../../game/features/player/practice_target.gd).
- [Guardado actual de resultados](../../game/core/services/level_progress.gd).
