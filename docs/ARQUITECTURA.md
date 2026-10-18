# Arquitectura de Super Diego

## Alcance y estado

Esta base configura un juego de plataformas lateral 2D para Android y Windows. Mantiene los ocho mundos, la posibilidad de volver a niveles superados, la eliminación de enemigos al saltar sobre ellos y los combates contra jefes mediante objetos lanzables como requisitos del desarrollo posterior.

`game/boot/entrance.tscn` inicia la presentación de aventuras y el mapa de ocho mundos. Solo Bosque Esmeralda está disponible y abre `game/boot/main.tscn`; el resto permanece bloqueado. Véase [entrada y mundos](ENTRADA_Y_MUNDOS.md). El entrenamiento se conserva en `game/features/player/practice.tscn` con cuerpo 2D, entrada, 16 estados de animación, sensores, seis objetos arrojadizos, plataformas, dianas, cámara, HUD, pausa y opciones persistentes de control. El primer nivel integra a Terrón y Moflete, punto de control, coleccionables, meta y progreso local. No hay autoloads. Desde 0.6.0 Bosque Esmeralda incluye música instrumental en bucle, volumen persistente y pausa del audio; los otros cinco enemigos siguen como conceptos. Desde 0.5.1 el nombre visible es Super Diego y el icono original del protagonista está en `game/assets/branding/`. El paquete Android `com.ramonc5.saltoheroes`, el directorio de datos `SaltoHeroes` y los identificadores internos se mantienen para conservar actualizaciones y guardados. [Identidad visual](IDENTIDAD_VISUAL.md).

Se conserva la elección artística «opción A» del plan previo, sin redefinirla en esta entrega. El proyecto usa escenas y recursos 2D; la especificación visual detallada y los recursos se incorporarán cuando se trabaje el arte.

## Colección permanente · 0.8.0

`CollectionProgress` (0.8.0) añade colección permanente por ID, vestuario y ayudante. Es un servicio `RefCounted` separado de `LevelProgress`, del intento y de las opciones. `boot/main.gd` lo compone e inyecta en `ForestStage`, `CollectionMenu` y `ForestFirefly`. `CollectionRewards`, bajo `core/contracts`, define hitos de 12, 45 y 100 hojas, tres fragmentos y los IDs de vestuario; no se añade autoload.

Las recogidas validan ID y tipo contra el manifiesto antes de ocultar el objeto. `collection.json`, esquema 1, persiste cada operación con temporal y renombrado, copia de seguridad y reversión ante error. Morir, cerrar o rejugar conserva colección y equipo; llaves y mecanismos mantienen las reglas del intento. Los resultados anteriores permanecen en `progress.json` y no se convierten en monedas sin IDs.

`PlayerWardrobe` aplica material propio sobre todas las poses raster existentes, con máscaras de material y tejido de helechos generado, conservando manos, agarre, movimiento y colisiones. `CollectionMenu` presenta vista previa, hitos, equipo, foco, scroll, zona segura y acciones de al menos 48 px. `ForestFirefly`, en `features/companions`, integra el acompañante sin colisión ni daño: aleteo de cuatro poses, pista lenta de secreto y recogida de hojas cercanas con oclusión contra el entorno. Los fragmentos se declaran en el recurso de nivel y su generador.

[Reglas de recompensas](RECOMPENSAS.md) · [Ficha](dinamicas/coleccion_bosque.json) · [Pruebas y límites](pruebas/coleccion-0.8.0.md). La posición del intento sigue sin guardarse. Android y Windows físicos pendientes.

## Decisión técnica

| Área | Decisión | Motivo |
| --- | --- | --- |
| Motor | Godot 4.7.2 estándar | Herramientas 2D y exportación nativa a las dos plataformas |
| Lenguaje | GDScript tipado | Integración directa con escenas, señales y recursos |
| Renderizado | Compatibility en escritorio y móvil | Base adecuada para 2D y una gama amplia de dispositivos |
| Composición | Escenas pequeñas con componentes | Reutilizar comportamientos sin una jerarquía de herencia extensa |
| Organización | Funcionalidades separadas y un núcleo reducido | Mantener juntas las escenas, scripts y recursos de cada mecánica |
| Datos futuros | Recursos Godot `.tres` con identificadores estables | Separar definiciones editables del progreso del jugador |
| Persistencia futura | JSON versionado bajo `user://` | Guardado local independiente de los recursos del juego |
| Servicios externos | Ninguno | La base se ejecuta sin servidor, cuentas ni dependencias adicionales |

La versión del motor se fija en `.godot-version`. Editor, plantillas de exportación y CI deben usar la misma versión. Una actualización debe comprobar importación, arranque y exportaciones antes de sustituir la versión fijada y los checksums del editor y de las plantillas de exportación.

## Módulos y responsabilidades

| Directorio | Responsabilidad futura |
| --- | --- |
| `game/boot/` | Crear los servicios de aplicación e iniciar el flujo del juego |
| `game/core/contracts/` | Recursos y contratos compartidos sin referencias a la interfaz |
| `game/core/components/` | Componentes reutilizables de las entidades |
| `game/core/services/` | Guardado, ajustes, reproducción musical y navegación entre escenas |
| `game/features/player/` | Movimiento, salto y estado del jugador |
| `game/features/enemies/` | Enemigos normales y detección de pisotón |
| `game/features/bosses/` | Fases de jefes y respuesta a impactos |
| `game/features/objects/` | Objetos que se pueden recoger y lanzar |
| `game/features/levels/` | Carga del nivel, puntos de control y finalización |
| `game/features/world_map/` | Selección de mundos y acceso a niveles desbloqueados |
| `game/ui/menus/` | Inicio, pausa, opciones y selección |
| `game/ui/hud/` | Información de la partida |
| `game/ui/touch_controls/` | Gestos táctiles por zonas, multitoque y adaptación a la zona segura |
| `game/data/worlds/world_01/` a `world_08/` | Definiciones futuras de los ocho mundos |
| `game/assets/textures/`, `audio/`, `fonts/` | Recursos audiovisuales |
| `game/localization/` | Traducciones |

### Reglas de dependencia

1. `core/contracts` no depende de `features`, `ui` ni `boot`.
2. Las funcionalidades usan los contratos y componentes compartidos. No buscan nodos de otras funcionalidades mediante rutas absolutas.
3. La UI emite intenciones y presenta datos; las reglas de combate y desbloqueo pertenecen a las funcionalidades.
4. `boot` compone los módulos y proporciona referencias explícitas a los servicios.
5. Las señales notifican hechos, como `level_completed`, y las llamadas explícitas solicitan acciones. Evitar un bus global para todos los eventos.
6. No añadir autoloads hasta que un servicio necesite persistir entre escenas. No hay autoloads registrados en esta base.

## Plataformas atravesables y restauración consolidada · 0.7.5

La consulta de postura inspecciona cada forma encontrada y respeta su colisión unilateral. Una repisa atravesable desde abajo no bloquea ponerse en pie; un techo sólido sigue exigiendo salir agachado. El cambio conserva la altura de los pies y el salto para aterrizar encima. Deslizar arriba después de agacharse libera la postura con el mismo contacto, sin convertirlo en salto ni lanzamiento.

El farol consolida las activaciones anteriores en una copia independiente. Al reaparecer se reconstruyen explícitamente el suelo de los puentes, las marcas y colisiones de los portones y el estado de sus dianas; omitir el reinicio de un nodo ya no se considera suficiente. Las aperturas posteriores se rearman completas. Resolver algo al volver atrás actualiza la copia anterior. Un nuevo farol consolida únicamente los puzzles que quedan antes de su punto de reaparición.

`test_real_recovery.gd` comprueba la primera plataforma real y los nueve portones con farol posterior, avanzando, muriendo, reanudando desde el menú y retrocediendo físicamente. Incluye una inyección explícita de pérdida de estado transitorio para verificar que la copia del farol restaura el paso. El APK Android comprueba con gestos reales que se agacha y vuelve a estar de pie bajo esa plataforma, con los pies a la misma altura y sin teletransporte. [Evidencia y límites](pruebas/recuperacion-0.7.5.md).

## Recuperación por farol y salida agachado · 0.7.4

`DiegoPlayer` conserva la cápsula baja cuando no cabe de pie, pero permite moverse a 90 px/s en ambas direcciones. `HeroTouchControls` deja deslizar abajo y arrastrar con el mismo dedo; solo reclama el eje al empezar el desplazamiento horizontal, para conservar también el uso de dos dedos. Salir del techo permite levantarse al soltar abajo. Se reutiliza la animación baja existente y se mantienen el descarte de saltos pendientes, el daño y la limpieza de entradas en pausa y reaparición.

`ForestStage.respawn_player()` usa el punto de reaparición como frontera espacial, independientemente del lugar de muerte o del orden temporal de las acciones. Conserva puentes, portones, dianas, activaciones y derrotas anteriores; reconstruye únicamente el tramo posterior. El extremo del puente y la barrera determinan a qué tramo pertenece un puzzle completo: una diana y su piña se rearman juntas aunque la estación quede antes del farol y accione algo posterior. Troncos, ascensor secreto, lianas y objetos generales siguen la misma regla según su recorrido o puesto de origen. Sin farol se reinicia todo desde el comienzo. Las llaves, hojas, cristales y el corazón secreto mantienen la persistencia del intento.

Los índices de enemigos derrotados se consolidan según su origen al avanzar el farol. Un enemigo posterior eliminado antes de activar el farol todavía debe reaparecer; un enemigo anterior eliminado al retroceder permanece derrotado. Solo las patrullas vivas posteriores vuelven a su puesto. La recuperación no crea objetos adicionales ni acumula derrotas repetidas. Cerrar o rejugar sigue creando un intento nuevo.

`test_player.gd` cubre el techo físico, salida y marcha atrás con teclado y contactos táctiles, uno o dos dedos y carrera automática. `test_checkpoint_recovery.gd` recorre faroles situados antes, después y dentro de un puzzle, muertes consecutivas, enemigos ya liberados, herramientas, ciclos y retorno a faroles anteriores. [Registro de validación](pruebas/recuperacion-0.7.4.md).

## Doble salto y agarre visible de Diego · 0.7.3

`PlayerInputSource.request_tap_jump()` conserva hasta dos pulsaciones táctiles pendientes, sin mantener `Input` global ni esperar a detectar un doble clic. `HeroTouchControls` asigna por defecto la izquierda a salto inmediato y la derecha a arrastre horizontal, agacharse y toque corto de recoger/lanzar. El modo de cada contacto se conserva al cruzar el centro; el primer arrastre horizontal se adueña del eje y los otros dedos pueden actuar. Los lados siguen siendo intercambiables y Pausa recibe los contactos antes que el juego. Un arrastre no genera saltos ni lanzamientos. La pausa, el foco y la reaparición limpian las órdenes.

`DiegoPlayer.jumps_used` limita a dos impulsos entre apoyos: 680 px/s desde suelo y 590 px/s para la corrección aérea, incluso durante el descenso. El toque táctil siempre da altura completa; teclado/mando conservan altura variable y su ajuste accesible. La tolerancia de borde y la anticipación siguen disponibles. Caer andando reserva un único salto aéreo; aterrizar o agarrarse renueva la reserva. El pisotón deja un salto después del rebote. Soltar la liana consume el impulso inicial, conserva velocidad horizontal durante 0,85 s y deja una corrección aérea. Actualizar contactos con `move_and_slide()` al soltar evita heredar un antiguo estado de suelo. Agacharse y las acciones no ejecutables descartan órdenes de salto.

El PNG nuevo `vine_hang_v001.png` conserva la identidad y vestuario de Diego. Se registra una pose de manos cerradas arriba, brazos elevados y piernas suspendidas. El recurso directo mide 1254 × 1254; el pivote [697, 1137], agarre [697, 149] y escala 0,12 sitúan las manos a −118,56 px del cuerpo. `Facing` gira alrededor de este agarre y compensa la aproximación física; no rota alrededor de los pies. Las manos permanecen en el nudo desde el primer fotograma, incluso con espejo. `double_jump` reinicia las dos poses existentes de ascenso durante 0,18 s; `vine_hang` es una pose única con balanceo del conjunto. Las velocidades de reproducción de caminar/correr/transportar acompañan la velocidad real. Colisiones y sensores siguen independientes del dibujo.

`test_player.gd` cubre 91 casos, incluidos contactos táctiles que llegan a la física. `test_player_movement.gd` añade 30 casos de límite de impulsos, caída, recuperación, daño y manos ancladas durante 480 pasos y dos orientaciones. `test_lianas_dianas.gd`, `test_forest_route.gd`, secreto, objetos y combate contrastan las transiciones. La CI ejecuta también capturas reales Compatibility en móvil/tablet y dos toques en el APK Android. Ninguna prueba automatizada acredita tacto o rendimiento en los dispositivos físicos del usuario. [Controles](CONTROLES_TACTILES.md) · [Protagonista](PROTAGONISTA.md).

## Tótem y recorrido bajo el bosque · 0.7.2

`ForestLevelDefinition.secret_grove` conserva la entrada en (11610, 600). `ForestStage._add_ground_with_tunnel` divide el terreno que coincide con la gruta: conserva el suelo profundo fuera y una cubierta de 64 px atravesable desde abajo dentro. Así existe un pasillo físico de **1890 px** entre x=10110 y x=12000, con suelo en y=1080 y extremos cerrados; no es una cueva superpuesta sobre tierra todavía sólida. Caminar por arriba mantiene la ruta anterior y agacharse sobre las hojas abre la trampilla.

El rastro opcional lleva a la izquierda hasta el brote en (10880, 1020) y el ascensor en x=10340. `ForestSecretGrove` usa `ForestMovingPlatform` con paradas amplias y colisión unilateral para regresar a la superficie por otro punto, sin saltarse los portones de la ruta principal. La cámara acompaña el trayecto y el límite de caída ampliado solo se aplica dentro del secreto. El premio aumenta de tres a cuatro corazones una sola vez por intento y se conserva al volver al farol; cerrar o rejugar lo reinicia. Ninguna llave está bajo tierra.

El tótem utiliza `secret_totem_v001.png`: corteza, musgo, helechos, talla y luz lateral coherentes con el bosque. No tiene colisiones, botones ni rótulos. El interior reutiliza la vegetación y la roca raster del atlas, con iluminación atenuada. El ascensor se dibuja por delante del fondo subterráneo. Las lianas usan `swinging_vine_v001.png` y la rama de raíces existente, con un lazo orgánico que identifica el agarre. Prompts exactos en `art/levels/bosque_esmeralda/prompts-pulido-2026-10-17.md`.

El agarre reduce el radio de 148 a 70 px, añade barrido relativo entre mano y nudo y aproxima el cuerpo durante varios pasos físicos. El arrastre aporta impulso a un resorte amortiguado; al saltar se transmite la velocidad horizontal real de la cuerda y se conserva el impulso durante 0,85 segundos con dirección aérea disponible. Caída, muerte y reaparición limpian el agarre y el impulso. `test_forest_route.gd` cruza las cinco lianas con entradas reales.

La marcha de enemigos avanza según distancia recorrida, con zancadas de 96 px para Terrón y 70 px para los otros perfiles terrestres. Pie plano durante el apoyo, arco durante el balanceo, muñecas con recorrido corto y respiración secundaria suave. El shader rota en píxeles del recorte para respetar la proporción del raster. El controlador acelera y frena, mientras el dibujo mezcla velocidad, alerta y caída. Las colisiones y los sensores mantienen su contrato. [Animaciones](ANIMACION_ENEMIGOS.md).

[Dinámica del secreto](dinamicas/gruta_hojas_vida.json) · [Lianas](dinamicas/lianas_dianas_barranco.json) · [Pruebas de recorrido](../tools/tests/test_secret_grove.gd). Android y Windows físicos pendientes.

## Contratos para las mecánicas

| Sistema | Contrato previsto |
| --- | --- |
| Entrada | El juego consulta acciones de `InputMap`, sin comprobar teclas concretas dentro del jugador |
| Jugador | Una escena `CharacterBody2D` con componentes y estados locales de movimiento |
| Pisotón | Un sensor superior y una comprobación de descenso/posición distinguen el pisotón del contacto lateral |
| Objetos lanzables | Estados libre, recogido y lanzado; los impactos solo se aceptan mientras el objeto sea válido para causar daño |
| Jefes | Cada jefe define su vulnerabilidad y fases; recibe impactos mediante un contrato común con los objetos lanzables |
| Nivel | Emite su finalización con un identificador estable; no decide por sí mismo el desbloqueo de otros niveles |
| Progreso | Un servicio conserva desbloqueos y mejores resultados por identificador de nivel |

El protagonista implementa entrada y movimiento; `StompTarget` valida descenso desde arriba y `ThrowableObject` distingue libre, recogido y lanzado. Las dianas responden mediante referencias y señales explícitas. Las opciones se guardan en `user://controls.cfg`, separadas del futuro progreso. Energía, velocidades y tiempos del prototipo son editables; no fijan dificultad definitiva ni patrones de jefes. [Detalles](PROTAGONISTA.md).

## Objetos arrojadizos integrados

El [catálogo de objetos](OBJETOS_ARROJADIZOS.md) incorpora seis recursos `ThrowableDefinition` bajo `game/features/objects/definitions/`. `ThrowableCatalog` conserva su orden e identificadores. `ThrowableObject` combina esos datos con una textura raster, una colisión independiente y los estados libre, sostenido, lanzado y roto. La suelta sigue usando el marcador de la animación de Diego.

Los barridos `move_and_collide` conservan el remanente de movimiento al rodar, deslizar o rebotar. `can_cause_thrown_damage()` exige lanzamiento activo, tiempo válido y velocidad suficiente; el receptor decide su vulnerabilidad mediante `receive_thrown_hit`. El primer receptor consume el lanzamiento. Las dianas prueban este contrato; todavía no hay jefes ni resistencias elementales.

El entrenamiento ofrece los seis objetos en el primer tramo y activa una reposición a los tres segundos de agotarse o romperse; recogerlos cancela ese temporizador. Salir de su área los devuelve al puesto original. La reposición periódica y el área de recuperación están desactivadas por defecto en la escena reutilizable. El entrenamiento asigna su propio rectángulo; los niveles futuros definirán sus límites sin coordenadas fijas en la entidad.

Las imágenes finales están en `game/assets/textures/objects/<id>/idle_v001.png`. Godot limita su importación a 256 × 256, sin mipmaps, y aplica el mismo recorte suave de alfa del protagonista. Las regiones normalizadas mantienen el encuadre al cambiar el tamaño de importación. Fichas, prompts, metadatos y evidencias están en `art/objects/`, fuera del APK. Nombres y balance son propuestas; no se asignan temáticas a los ocho mundos.

## Llaves y puertas de salida

Cada intento exige tres llaves diferentes. `LevelKeyDefinition`, bajo `game/features/levels/keys/`, separa las texturas y regiones normalizadas de la recogida `LevelKey`. `ForestStage` registra las ranuras obtenidas, emite `keys_changed` y valida las tres antes de emitir `level_completed`. `KeyExitDoor` muestra las ranuras, bloquea físicamente el paso y se abre al recibir las tres; su sensor también comprueba al jugador que ya estaba delante al abrirse.

`ForestLevelDefinition` añade `key_definition` y tres `key_positions`. El HUD presenta contador, iconos, números y marcas. Las llaves se conservan al volver al farol; reiniciar crea un intento nuevo. Los resultados añaden `keys` y el guardado `best_keys`, con lectura compatible del esquema 1. El bosque integra tres variantes de ramas; otros siete recursos de ambiente son propuestas sin asignación a los mundos pendientes. [Catálogo visual y reglas](LLAVES_Y_PUERTAS.md).

## Ocho mundos y niveles rejugables

Los identificadores de mundo serán `world_01` a `world_08`. Cada nivel recibirá un identificador único independiente del nombre visible y de su ruta de archivo.

Las futuras definiciones de mundo enumerarán sus niveles, sus dependencias de desbloqueo y la referencia al jefe. El primer nivel es `world_01_level_01`, definido por `game/data/worlds/world_01/level_01.tres`; las restantes definiciones siguen pendientes.

El guardado distinguirá `unlocked`, `completed` y los mejores resultados. Completar un nivel no lo bloqueará: el mapa permitirá volver a cualquier nivel desbloqueado. Rejugarlo conservará los desbloqueos y solo sustituirá un mejor resultado cuando corresponda.

El progreso se guardará bajo `user://` con una versión de esquema, escritura a un archivo temporal antes de reemplazar el principal y tratamiento de archivos ausentes o inválidos. Los ajustes de accesibilidad y controles se almacenarán separados del progreso. No guardar partidas dentro de `res://`.

## Presentación y rendimiento

- Vista lateral y física 2D. Usar nodos `Node2D`, `CharacterBody2D`, `Area2D`, `TileMapLayer`, `Camera2D` y `Control` según la responsabilidad.
- Resolución lógica inicial de 1280 × 720, escalado `canvas_items` y aspecto `expand`. La cámara, límites y UI deberán adaptarse al área visible adicional en otras proporciones.
- Orientación horizontal en móvil. Los futuros controles táctiles respetarán los recortes y la zona segura del dispositivo.
- Objetivo de 60 FPS a validar en dispositivos reales; física configurada a 60 pasos por segundo. Es un objetivo, no una medición del entrenamiento en un móvil.
- Texturas con filtrado lineal como base para recursos 2D de alta resolución. La selección final de compresión, atlas y tamaños se medirá al incorporar arte.

## Plataformas de raíces móviles

La segunda dinámica del bosque compone `MovingPlatformDefinition` y `ForestMovingPlatform` en `game/features/levels/mechanisms/`. El recurso define extremos, ancho y tiempos; el cuerpo `AnimatableBody2D` actualiza su posición en física y transporta a Diego mediante su `CharacterBody2D` existente, sin reparentarlo ni modificar su controlador. La colisión de entorno es atravesable desde abajo. `ForestStage` proporciona datos, pistas y reinicio del ciclo después de trasladar al jugador al farol. El suelo inferior y el retorno de los ciclos evitan perder acceso a la tercera llave.

El ensayo horizontal y el ascensor de la llave son dos usos de una misma dinámica. Se reutiliza el PNG de raíces del puente. [Ficha y límites de validación](dinamicas/troncos_viajeros.md).

## Skill de creación de personajes

Utilizar el skill del repositorio [`generar-personajes-salto-heroes`](../.agents/skills/generar-personajes-salto-heroes/SKILL.md) para los futuros protagonistas, enemigos y jefes. Invocarlo como `$generar-personajes-salto-heroes`; `AGENTS.md` también dirige las tareas de personajes a este flujo.

| Elemento | Configuración |
| --- | --- |
| Ubicación | `.agents/skills/generar-personajes-salto-heroes/` |
| Base | Flujo `imagegen` de OpenAI; procedencia y referencia de versión en `references/fuentes.md` |
| Requisitos | Matriz de requisitos confirmados, criterios derivados y decisiones pendientes en `references/requisitos.md` |
| Generación | Herramienta integrada `image_gen`, referencias visuales coherentes y transparencia real para sprites |
| Entrega | PNG RGBA, acciones por rol, ficha de identidad, prompts y metadatos; contrato en `references/produccion-godot.md` |
| Verificación | Comprobador de PNG de solo lectura y revisión visual de continuidad, raíz y legibilidad |
| Dependencias de autoría | Herramienta de imágenes disponible; Python y Pillow para el comprobador local |
| Dependencias del juego | Ninguna añadida por el skill |

El skill conserva los requisitos de escenas 2D, acabado pulido sin apariencia de dibujo plano, Android y Windows, ocho mundos y niveles rejugables. Incluye poses para el pisotón de enemigos y para recoger/lanzar objetos contra jefes. La descripción exacta de la «opción A» sigue pendiente de incorporar; las decisiones nuevas se registrarán como propuestas.

Separar el material de autoría futuro bajo `art/characters/`, con `art/.gdignore`, de los PNG finales bajo `game/assets/textures/characters/`. Los perfiles de exportación excluyen `art/`, `.agents/` y `AGENTS.md`. El skill es una herramienta de producción fuera de la ejecución del juego; no genera personajes en tiempo de juego.

El [catálogo de personajes](PERSONAJES.md) registra siete enemigos normales: **Terrón, Moflete, Goterón, Vainete, Plumín, Remiendo y Nóctilo**. Cada uno tiene ficha, concepto raster 2D propuesto, PNG transparente con revisión registrada, encargo, prompts, metadatos y revisión en `art/characters/<character_id>/`. El skill exige mantener este registro y comprobar la subida a Git cuando se solicite.

El protagonista [Diego](../art/characters/diego/ficha.md) añade once hojas PNG de ejecución, 48 poses y 14 estados de `SpriteFrames`, con regiones explícitas y pivote de apoyo. Referencia, prompts, metadatos y revisión están bajo `art/characters/diego/`. Terrón y Moflete tienen integración jugable y desde 0.5.3 animan miembros mediante `EnemyVisual` y malla raster 2D; las hojas de fotogramas de enemigos siguen pendientes y los otros cinco conservan su estado de concepto. Nóctilo tiene aleteo visual armónico en el visor desde 0.5.3; su IA y combate de vuelo siguen pendientes. El entrenamiento no asigna contenido a los ocho mundos.

## Capas de colisión reservadas

| Capa | Nombre | Uso futuro |
| --- | --- | --- |
| 1 | `environment` | Suelo, paredes y plataformas |
| 2 | `player` | Cuerpo del jugador |
| 3 | `enemies` | Enemigos y jefes |
| 4 | `throwable_objects` | Objetos recogibles y lanzables |
| 5 | `hazards` | Peligros del escenario |
| 6 | `collectibles` | Coleccionables |
| 7 | `interaction_sensors` | Detección de interacción y combate |

El jugador usa capa 2 y consulta las capas 1 y 3; los objetos usan capa 4 y los sensores capa 7. Las plataformas y dianas declaran sus capas explícitamente. Las escenas futuras conservarán estas responsabilidades.

## Accesibilidad prevista

Las acciones iniciales incluyen teclado y mando. Al crear la interfaz se añadirán navegación con foco visible, textos escalables y legibles, controles reasignables y gestos táctiles ajustables. Las señales relevantes combinarán forma, texto o sonido para evitar depender únicamente del color. Se preverán opciones para reducir sacudidas y destellos, además de pausa accesible y volúmenes separados.

Ya están implementados contactos simultáneos, gestos sin botones fijos, recorrido y lados ajustables, carrera automática opcional, salto completo con pulsación, teclado reasignable, foco visible y pausa al perder el foco. La protección de daño no parpadea y la cámara no aplica sacudidas. La música tiene volumen independiente y silencio. Escalado avanzado de textos, lectores de pantalla y pruebas físicas quedan pendientes.

## Compilación continua para Android

El workflow `.github/workflows/validate.yml` valida el proyecto y genera automáticamente un APK de pruebas firmado para Android ARM64 en cada envío y pull request. Usa la versión fijada del editor y sus plantillas oficiales, verifica ambas descargas y configura Java 17 y el SDK Android en el runner.

La exportación mantiene el perfil Android existente, sin Gradle. Antes de publicar el artefacto se verifica la firma, el identificador del paquete y la arquitectura. Los APK se conservan en Actions durante 30 días junto a su checksum y los metadatos del commit; las claves de depuración permanecen fuera de Git y se reutilizan mediante una caché temporal.

La integración anterior 0.4.2 ejecutaba 297 comprobaciones: 88 del protagonista y controles, 63 de objetos arrojadizos, 61 del nivel y llaves, 55 de dianas y puentes, 27 de plataformas móviles y tres de los datos binarios extraídos del APK. Genera capturas Compatibility de móvil y tablet e instala el APK ARM64 real en emulador Android API 35 para comprobar las nueve patrullas y revisar su visibilidad. La evidencia y los límites de esta prueba están en [el diagnóstico de enemigos](pruebas/apk-enemigos-0.4.2.md). La firma estable de distribución y las pruebas en dispositivos reales se configurarán al preparar una versión para usuarios. Las instrucciones de descarga, instalación y cambio de firma están en [Desarrollo y exportación](DESARROLLO.md#integración-continua).

## Referencias técnicas

- [Godot 4.7.2 estándar](https://godotengine.org/download/archive/4.7.2-stable/).
- [Comparación oficial de renderizadores](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html).
- [Exportar a Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).
- [Exportar a Windows](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).


## Bosque Esmeralda 1-1 · 0.3.0

`ForestLevelDefinition` separa los datos editables del nivel de `ForestStage`, que crea suelo, plataformas de una dirección, coleccionables, marcadores y patrullas. El nivel emite `level_completed`, `checkpoint_reached`, `counts_changed` e `hint_requested`; `boot/main.gd` recibe esas señales y compone cámara, HUD y pausa mediante la base de entrenamiento `boot/practice.gd`.

`ForestEnemy` reutiliza `StompTarget` y `receive_thrown_hit`. `DiegoPlayer.fall_limit_y` permite al nivel decidir su límite de caída, manteniendo el valor anterior como predeterminado del entrenamiento. `LevelProgress` guarda JSON de esquema 1 mediante un temporal y renombrado, mantiene el nivel desbloqueado y conserva máximos de coleccionables y mínimo de tiempo al rejugar. Los ajustes siguen separados del progreso.

Los PNG HD de fondo, terreno y cuatro elementos de escenario están en `game/assets/textures/environments/bosque_esmeralda/`; los recortes se hacen con `AtlasTexture` o regiones de dibujo. La colisión nunca se infiere del píxel. Fondo a velocidad 0,17 respecto a la cámara, árboles en plano intermedio y helechos en primer plano componen la profundidad, íntegramente 2D. Prompts y revisión en `art/levels/bosque_esmeralda/`. [Diseño y controles del nivel](BOSQUE_ESMERALDA.md).



## Agacharse

La acción `crouch` se integra en InputMap, los gestos, la reasignación y el bloqueo de teclas al reanudar. `DiegoPlayer` intercambia cápsulas propias de 98 y 58 px, conserva la base y comprueba la forma erguida contra las capas del cuerpo antes de levantarse. La consulta se separa del suelo por el margen de seguridad. `PlayerTuning.crouch_height` permite ajustar la altura. El estado limita el avance a `PlayerTuning.crouch_speed` (90 px/s), permite invertir dirección bajo techo, mantiene el objeto a menor altura y conserva daño y sensores. La postura baja permanece hasta poder levantarse; el arrastre funciona con el mismo contacto que mantiene abajo o con otro dedo. [Reglas y controles](PROTAGONISTA.md).

## Skill de dinámicas y progresión prevista

Usar [`crear-dinamicas-salto-heroes`](../.agents/skills/crear-dinamicas-salto-heroes/SKILL.md) al diseñar o revisar mecánicas y recorridos. `AGENTS.md` dirige estos encargos a su inventario, catálogo, reglas, plantillas JSON y comprobador de consistencia. [Criterios y progresión](DINAMICAS.md).

El plan establece tres aventuras antes del jefe de cada uno de los ocho mundos. Cada aventura conserva tres llaves y debe dimensionarse para al menos 15 minutos de ruta principal en primera partida normal, con objetivo inicial estimado de 18–22 minutos. Los secretos y repeticiones no cuentan; la duración se verificará jugando. El encuentro con el jefe mantiene la condición de combate mediante objetos lanzados y no hereda automáticamente el mínimo de las aventuras.

Las fichas futuras se guardarán en `docs/dinamicas/` y `docs/niveles/`; constituyen material de autoría y no sustituyen los recursos `.tres`, señales ni reglas de las funcionalidades. El skill y su comprobador no añaden dependencias al juego. Mantenerlos fuera de la exportación como el resto de `.agents/`.

El avance agachado está integrado desde 0.7.4. Setas de rebote, placas de peso y guardado de intentos siguen pendientes. Las plataformas móviles ya están integradas. La integración 0.3.0 añade dianas conectadas a dos puentes y tres faroles al bosque actual.

### Dianas y puentes integrados

`RootBridgeDefinition` separa los datos de estación; `ForestThrowTarget` valida impactos y emite una activación única; `RootBridge` despliega la imagen durante 0,6 segundos y después habilita suelo estático. `ForestStage` compone referencias y conserva `activated_mechanisms` durante el intento. Al reaparecer (desde 0.7.4) conserva los puentes y barreras anteriores al farol junto con sus activaciones y dianas. Solo cierra y rearma los posteriores, recuperando las piñas del mismo puzzle; no guarda el intento en disco. Las dianas usan la capa 7 de interacción y los arrojadizos la incluyen en sus barridos; Diego no colisiona con ellas. El puente usa la capa de entorno.

Los datos incluyen dos estaciones, recuperación inferior, posición nueva de la segunda llave y tres faroles. La reaparición solo avanza a índices de farol posteriores. La cámara aumenta suavemente la anticipación en las estaciones y sigue la recuperación inferior. Las texturas raster tienen límites de importación de 1024 y 256 píxeles. [Diseño, evidencia y pendientes](dinamicas/puente_diana.md).



## Ampliación del bosque · 0.5.0

`ForestLevelDefinition` añade pasos `ForestRootGateDefinition` y nombres/inicios de tramo. `ForestRootGate` mantiene internamente sus dos activaciones y retira la colisión del paso al completarlas; desde 0.6.1 no muestra marcas ni iconos. Reutiliza `RootBridgeDefinition` para los puestos y `ForestThrowTarget` para impactos, sin crear una segunda forma de recoger o lanzar. Los pasos nunca se vuelven a cerrar durante el intento.

`ForestEnemy` distingue patrulla, aviso, persecución y retorno. La visión consulta la capa de entorno; el nivel deduce los límites de suelo o plataforma de los rectángulos de datos. Un sondeo adelantado y límites de cuerpo impiden abandonar bordes. La simulación de enemigos lejanos se omite y solo se animan/detectan coleccionables cercanos. `DiegoPlayer.recover_energy` cura un farol nuevo sin alterar posición, controles ni objeto sostenido. La cámara sigue alturas sin coordenadas exclusivas del antiguo ascensor.

`boot/main.gd` acepta un recurso de nivel configurable antes de entrar en el árbol. El juego usa el bosque completo; las suites antiguas de mecanismos inyectan un fixture estable para mantener sus pruebas físicas. Las suites nuevas prueban el recurso completo, IA y ruta geométrica continua. `tools/authoring/build_forest_level.py` recompone el `.tres` de autoría; no se ejecuta ni se exporta dentro del juego. Los JSON de diseño permanecen separados.

La CI suma 474 comprobaciones, exige las suites nuevas y verifica 81 enemigos con arte en el APK instalado, además de conservar los contratos anteriores. La ruta automatizada de geometría excluye el combate y no acredita duración del público objetivo. Consultar [el recorrido](BOSQUE_ESMERALDA.md) para los límites de validación y el presupuesto estimado.



## Ajuste 0.5.2 · Persecución desde plataformas y presentación

La petición posterior permite a todos los enemigos perseguir y bajar de estructuras. Sustituye la restricción anterior de los guardianes de plataforma durante la persecución; la patrulla tranquila sigue respetando los bordes. El HUD usa iconos con cantidades, el salto tiene un impulso de 680 px/s y la cámara acompaña la caída sin limitarse a 260 px/s. El componente `game/ui/hud/hud_counter.gd` reúne presentación y descripciones accesibles; las reglas de combate y recogida siguen en sus funcionalidades. [Detalles y pruebas](PULIDO_0.5.2.md).


## Animación de enemigos · 0.5.3

`EnemyMotionProfiles` fija pivotes, zonas elípticas, amplitudes y fases por anatomía. `EnemyVisual` comparte geometría inmutable entre instancias y mantiene materiales independientes; el shader Compatibility deforma una malla raster de 40 × 40 celdas sin cambiar los PNG ni los cuerpos físicos. `ForestEnemy` avanza el ciclo con `delta` y velocidad real, y conserva pausa, suspensión lejana y derrota. El visor permite revisar los siete diseños, pausar y reducir movimiento. Las cinco integraciones visuales nuevas no incorporan IA ni contenido a los niveles. [Contrato, evidencias y límites](ANIMACION_ENEMIGOS.md).



## Música por nivel, reaparición y señales visuales · 0.6.0

### Música del Bosque Esmeralda

`ForestLevelDefinition.music_stream` es una referencia editable `AudioStream`. El recurso real de `world_01_level_01` asigna `game/assets/audio/music/bosque_esmeralda.ogg`; un nivel sin pista permanece en silencio. Los futuros niveles deben seleccionar una composición coherente con su ambiente en sus propios datos, sin deducir música por nombre ni copiar automáticamente la del bosque.

`boot/main.gd` compone una única instancia de `LevelMusic` (`AudioStreamPlayer`) bajo la escena y entrega el recurso. No hay autoload, descargas ni síntesis durante la partida. El reproductor usa `PROCESS_MODE_PAUSABLE`: pausa, derrota y pérdida de foco suspenden el audio junto al juego; continuar o reaparecer retoma la misma voz. Reiniciar o cambiar de escena libera el reproductor anterior. El bus `Music`, en `game/assets/audio/default_bus_layout.tres`, reserva mezcla separada respecto a futuros efectos.

Desde 0.6.1 la composición original **Esmeralda en marcha** sustituye a Senderos de Esmeralda. Usa batería con bombo, caja y charles, bajo FM sincopado, acordes estéreo con séptimas y novenas, arpegios, melodía de sintetizador y transiciones. Es una dirección de plataformas electrónica y más enérgica, sin flauta ni emulación de chips de 8 bits. Son 48 compases de 4/4 a 128 BPM, 90 segundos, con dos secciones melódicas, variaciones de instrumentación y colas circulares para enlazar el bucle. Se distribuye como Ogg Vorbis estéreo a 44,1 kHz; la importación fija `loop=true`, 192 pulsos y cuatro pulsos por compás. `tools/authoring/compose_forest_music.py` conserva partitura, síntesis determinista y procedencia sin samples de terceros. Requiere NumPy, SciPy y FFmpeg solo en autoría; el juego reproduce el archivo ya preparado. Esta pieza se puede usar y modificar como parte del proyecto.

`ControlSettings` añade `audio/music_volume` a `user://controls.cfg` sin borrar teclas ni controles anteriores. El valor inicial es 0,6; el menú de pausa ofrece un deslizador de 0 a 100, con foco de teclado y nombre accesible. Cero silencia. El bus añade −6 dB de margen. Los efectos y las músicas de otros niveles siguen pendientes; no existe aún ajuste de volumen de efectos.

### Enemigos y faroles

Cada `ForestEnemy.spawn_index` identifica su entrada en `enemy_spawns`. `ForestStage` registra los índices derrotados desde el último farol, incluso después de que sus nodos desaparezcan. Antes del primer farol el registro empieza en el inicio del nivel. Activar un farol posterior consolida las derrotas cuyo origen queda antes y mantiene pendientes las posteriores; revisitar uno anterior no cambia ese estado.

Al reaparecer, el nivel reconstruye exactamente las patrullas registradas desde sus datos originales: posición, tipo, límites, sensores, salud activa, animación y persecución. Si una animación de derrota aún existe, primero retira esa instancia. Los enemigos activos posteriores al farol vuelven a su patrulla inicial. Las derrotas consolidadas permanecen eliminadas durante el intento. El contador descuenta los enemigos restaurados para impedir sumar varias veces el mismo combate. Desde 0.7.4 la regla es espacial: una derrota anterior al punto de reaparición se conserva también si se produjo al retroceder.

Llaves, hojas y cristales se conservan. Desde 0.7.4 solo se rearman los mecanismos posteriores al farol, junto con sus piñas y troncos. Reiniciar voluntariamente crea un intento completo con todos los enemigos. No se guarda el intento a mitad del nivel en disco.

### Escenario sin rótulos ni iconos · 0.6.1

Se retiran las insignias y flechas flotantes de dianas, enemigos, faroles, troncos y salida, así como las dos marcas gráficas de las raíces y las guías superpuestas de gestos. Se elimina `WorldCue`. Las instrucciones y los ajustes permanecen en pausa; las llaves y la apertura física de los pasos comunican el progreso. El HUD conserva los contadores de vida, llaves, hojas y cristales con sus cantidades y las descripciones accesibles anteriores. Esta retirada afecta a las ayudas flotantes del escenario, no a los indicadores de recursos que el usuario pidió anteriormente.

### Rotura y reconstrucción de dianas · 0.6.1

`ForestThrowTarget.receive_thrown_hit` exige un arrojadizo lanzado válido. El primer impacto desactiva el sensor y oculta el disco entero. `break_apart` reparte la misma textura en ocho sectores `Polygon2D`, con UV originales, desplazamiento, giro y desvanecimiento durante 0,65 segundos. Los fragmentos no tienen colisión y su tween hereda la pausa. No hay insignia de confirmación, destello ni sacudida; el objeto roto y la apertura real del paso son la respuesta visual.

Al reaparecer, `ForestStage` llama a `reset_to_intact` para **todas** las dianas del nivel, incluidas las situadas antes del farol. Se cancela cualquier rotura en curso, se retiran los fragmentos, vuelve el disco entero y se reactiva la capa 7 para poder romperlas de nuevo. Desde 0.6.3 los mecanismos se rearman mientras las llaves del intento se conservan. Una diana reparada puede emitir otro impacto, pero `activated_mechanisms` evita repetir activaciones y duplicar el progreso de puentes o raíces. Reiniciar crea el nivel completo nuevo.

`tools/tests/test_breakable_targets.gd` verifica objetos libres/sostenidos, impacto válido, ocho fragmentos, pausa, limpieza, reparación durante la rotura, dianas anteriores al farol, impactos repetidos tras reparar, ausencia de iconos y conservación del progreso. Las suites de puentes, IA y audio actualizan las expectativas sustituidas por esta petición. La música conserva volumen, silencio, pausa y un único reproductor por escena. El entrenamiento retira también sus insignias.


### Cristales irregulares, reinicio de puentes y pisada de Moflete · 0.6.3

`ForestThrowTarget` genera 19 celdas de Voronoi de distinto tamaño sobre la textura de la diana, con UV correctos, aristas brillantes y un destello corto. Los fragmentos salen despedidos, giran, caen acelerando y se desvanecen en 0,72 segundos. No tienen colisión, comparten material raster y respetan la pausa. La semilla aleatoria local permite repetir pruebas sin alterar el RNG del juego.

**Comportamiento histórico 0.6.3, sustituido por la recuperación por farol de 0.7.4:** `ForestStage.respawn_player()` rearmaba TODOS los puentes, incluso si se estaban desplegando, y las barreras de dos dianas; estas cancelan sus tweens y recuperan la colisión. Vacía `activated_mechanisms` y devuelve intactas todas las dianas, de forma que deben activarse de nuevo. Permanecen llaves, hojas, cristales, faroles y las reglas existentes de enemigos derrotados desde el último farol.

`EnemyVisual` introduce el modo `foot` en el perfil de Moflete: ambos pies se elevan y apoyan por turnos, se desplazan longitudinalmente con la velocidad y reducen su recorrido al frenar o caer. El movimiento no afecta al cuerpo físico ni a los sensores. La regresión prueba fases opuestas, desplazamiento y apoyo, geometría irregular, pausas y reactivación.


## Nivel compacto y liana con dianas · 0.7.0

`ForestLevelDefinition.vine_crossings` declara los orígenes del obstáculo; `ForestStage` instancia `ForestVineCrossing` y conserva su registro para restaurarlo al reaparecer. `DiegoPlayer.vine_climb_zone` habilita ascender manteniendo la acción `jump` que ya controla el deslizamiento ascendente en Android/Windows. Soltar la liana aplica un impulso hacia la primera diana; `ForestVineTarget` define un cuerpo unilateral, rebote y rotura con recuperación automática sin recompilar texturas ni imponer iconos flotantes. Un sensor de vacío penaliza con energía y devuelve al inicio del barranco cuando quedan vidas. El acortamiento usa diez tramos, tres llaves distribuidas y salida sin temporizador. `tools/authoring/build_forest_level.py` es la fuente reproducible de `level_01.tres` y la ficha de duración incluye la excepción explícita solicitada por el usuario (9,2–10,94 min *estimados*). El comprobador de dinámicas exige justificarla con solicitud y fecha; futuras aventuras conservan el mínimo de 15 min por defecto. La CI incorpora `test_lianas_dianas.gd` y verifica `vine_crossings` en el recurso exportado del APK. Las pruebas automatizadas no sustituyen jugabilidad y duración observadas en dispositivos reales.


## Cambio de mecánica: balanceo y transferencia entre lianas · 0.7.2

El sistema anterior de trepa automática de `DiegoPlayer.vine_climb_zone` se ha retirado. `ForestSwingingVine` es un nodo 2D que calcula el nudo de agarre y la velocidad tangencial del péndulo; cinco instancias bajo `ForestVineCrossing` tienen fases independientes y siguen moviéndose aunque Diego no esté sujeto. `DiegoPlayer` mantiene referencias a lianas cercanas, se agarra automáticamente cuando alcanza un nudo en el aire, sigue el movimiento mientras está colgado y responde a un nuevo `jump` desprendiéndose con impulso direccional. El bloqueo temporal impide reenganche accidental inmediato al mismo nudo y se limpia en muerte, caída, celebración y reaparición. La colisión de terreno no se modifica y la transición no requiere nuevos botones, textos flotantes ni consumo de lanzables. La prueba de ruta y la suite de interacción cubren salto/agarrar/balancear/soltar y recuperación; el comportamiento táctil debe revisarse en dispositivos físicos.


## Señalización diegética de secretos · Tótem del bosque

`ForestSecretTotem` es un `Node2D` independiente, sin `CollisionObject2D`, que dibuja un tótem original de madera, raíces, cara tallada y hojas. Su representación usa `_draw()` y anima únicamente con `_process()` dentro de un radio de 390 px respecto a `DiegoPlayer`: hojas oscilantes, tres hojas flotantes y luz suave. La pausa del árbol de escena interrumpe el ciclo. Evita textos, carteles, controles nuevos y materiales compartidos.

`ForestStage._build_secret()` lo instancia una sola vez a 180 px a la izquierda del centro de la trampilla definido en `ForestLevelDefinition.secret_grove`; `start()` inyecta la referencia del jugador para la proximidad. La señalización no modifica el acceso (agacharse), la geometría, la recompensa ni el retorno en ascensor. `test_secret_grove.gd` cubre ubicación, ausencia de colisión y animación en proximidad, y `capture_forest.gd` guarda `preview_secret_totem.png` durante la CI. El dibujo requiere revisión visual del PNG producido por Godot.




## Entrada y mapa · 0.9.0

`WorldCatalog` ofrece ocho identificadores estables, etiquetas editables y una única ruta jugable. `AdventureWorldMap` presenta la ilustración raster, botones numerados, candados y estado textual. `AdventureIntro` reutiliza SpriteFrames y escalas de Diego en ocho viñetas decorativas de 3,2 segundos, sin cuerpo físico. El botón Jugar ahora está disponible desde el primer instante. El ajuste de movimiento reducido persiste en controls.cfg y detiene el montaje y el pulso del mapa.

Volver al mapa desde pausa libera entradas, audio y escena del intento; la colección y mejores resultados conservan sus servicios. La vuelta inyecta initial_page en la nueva escena, sin autoload ni metadatos globales. No se desbloquean otros mundos al completar el bosque. Los siete ambientes pendientes del catálogo se usan como propuestas de ilustración y nombres editables, sin añadir niveles.
