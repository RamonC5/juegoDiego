# Arquitectura de Salto Heroes

## Alcance y estado

Esta base configura un juego de plataformas lateral 2D para Android y Windows. Mantiene los ocho mundos, la posibilidad de volver a niveles superados, la eliminación de enemigos al saltar sobre ellos y los combates contra jefes mediante objetos lanzables como requisitos del desarrollo posterior.

`game/boot/main.tscn` compone la primera prueba jugable de Diego: cuerpo 2D, entrada, 13 estados de animación, sensores, seis objetos arrojadizos, plataformas, dianas, cámara, HUD, pausa y opciones persistentes de control. No hay autoloads, mundos, niveles definitivos, progreso ni audio. Los seis enemigos siguen como conceptos de autoría. Se conserva el icono provisional SH.

Se conserva la elección artística «opción A» del plan previo, sin redefinirla en esta entrega. El proyecto usa escenas y recursos 2D; la especificación visual detallada y los recursos se incorporarán cuando se trabaje el arte.

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
| `game/core/services/` | Guardado, ajustes y navegación entre escenas |
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

## Ocho mundos y niveles rejugables

Los identificadores de mundo serán `world_01` a `world_08`. Cada nivel recibirá un identificador único independiente del nombre visible y de su ruta de archivo.

Las futuras definiciones de mundo enumerarán sus niveles, sus dependencias de desbloqueo y la referencia al jefe. Ningún nivel concreto está definido todavía.

El guardado distinguirá `unlocked`, `completed` y los mejores resultados. Completar un nivel no lo bloqueará: el mapa permitirá volver a cualquier nivel desbloqueado. Rejugarlo conservará los desbloqueos y solo sustituirá un mejor resultado cuando corresponda.

El progreso se guardará bajo `user://` con una versión de esquema, escritura a un archivo temporal antes de reemplazar el principal y tratamiento de archivos ausentes o inválidos. Los ajustes de accesibilidad y controles se almacenarán separados del progreso. No guardar partidas dentro de `res://`.

## Presentación y rendimiento

- Vista lateral y física 2D. Usar nodos `Node2D`, `CharacterBody2D`, `Area2D`, `TileMapLayer`, `Camera2D` y `Control` según la responsabilidad.
- Resolución lógica inicial de 1280 × 720, escalado `canvas_items` y aspecto `expand`. La cámara, límites y UI deberán adaptarse al área visible adicional en otras proporciones.
- Orientación horizontal en móvil. Los futuros controles táctiles respetarán los recortes y la zona segura del dispositivo.
- Objetivo de 60 FPS a validar en dispositivos reales; física configurada a 60 pasos por segundo. Es un objetivo, no una medición del entrenamiento en un móvil.
- Texturas con filtrado lineal como base para recursos 2D de alta resolución. La selección final de compresión, atlas y tamaños se medirá al incorporar arte.

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

El [catálogo de personajes](PERSONAJES.md) registra seis enemigos normales: **Terrón, Moflete, Goterón, Vainete, Plumín y Remiendo**. Cada uno tiene ficha, concepto raster 2D propuesto, PNG transparente con revisión registrada, encargo, prompts, metadatos y revisión en `art/characters/<character_id>/`. El skill exige mantener este registro y comprobar la subida a Git cuando se solicite.

El protagonista [Diego](../art/characters/diego/ficha.md) añade diez hojas PNG de ejecución, 44 poses y 13 estados de `SpriteFrames`, con regiones explícitas y pivote de apoyo. Referencia, prompts, metadatos y revisión están bajo `art/characters/diego/`. Los seis enemigos siguen como material de autoría, con animaciones e integración pendientes. El entrenamiento no asigna contenido a los ocho mundos.

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

Ya están implementados contactos simultáneos, gestos sin botones fijos, recorrido y lados ajustables, carrera automática opcional, salto completo con pulsación, teclado reasignable, foco visible y pausa al perder el foco. La protección de daño no parpadea y la cámara no aplica sacudidas. Audio, escalado avanzado de textos, lectores de pantalla y pruebas físicas quedan pendientes.

## Compilación continua para Android

El workflow `.github/workflows/validate.yml` valida el proyecto y genera automáticamente un APK de pruebas firmado para Android ARM64 en cada envío y pull request. Usa la versión fijada del editor y sus plantillas oficiales, verifica ambas descargas y configura Java 17 y el SDK Android en el runner.

La exportación mantiene el perfil Android existente, sin Gradle. Antes de publicar el artefacto se verifica la firma, el identificador del paquete y la arquitectura. Los APK se conservan en Actions durante 30 días junto a su checksum y los metadatos del commit; las claves de depuración permanecen fuera de Git y se reutilizan mediante una caché temporal.

El flujo ejecuta 55 pruebas de comportamiento del protagonista y los controles, además de 63 de los objetos arrojadizos antes de exportar el entrenamiento. La firma estable de distribución y las pruebas en dispositivos reales se configurarán al preparar una versión para usuarios. Las instrucciones de descarga, instalación y cambio de firma están en [Desarrollo y exportación](DESARROLLO.md#integración-continua).

## Referencias técnicas

- [Godot 4.7.2 estándar](https://godotengine.org/download/archive/4.7.2-stable/).
- [Comparación oficial de renderizadores](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html).
- [Exportar a Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).
- [Exportar a Windows](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).

