# Arquitectura de Salto Heroes

## Alcance y estado

Esta base configura un juego de plataformas lateral 2D para Android y Windows. Mantiene los ocho mundos, la posibilidad de volver a niveles superados, la eliminación de enemigos al saltar sobre ellos y los combates contra jefes mediante objetos lanzables como requisitos del desarrollo posterior.

La única escena creada es `game/boot/main.tscn`, con un `Node2D` vacío. No hay scripts de juego, autoloads, personajes, niveles, datos de progreso, menús ni recursos audiovisuales. Los apartados de diseño siguientes establecen contratos para futuras implementaciones; no describen funciones ya disponibles.

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

La versión del motor se fija en `.godot-version`. Editor, plantillas de exportación y CI deben usar la misma versión. Una actualización debe comprobar importación, arranque y exportaciones antes de sustituir la versión fijada y su checksum.

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
| `game/ui/touch_controls/` | Botones táctiles y adaptación a la zona segura |
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

Estos contratos no fijan todavía dificultad, número de niveles por mundo, daños ni patrones de los jefes.

## Ocho mundos y niveles rejugables

Los identificadores de mundo serán `world_01` a `world_08`. Cada nivel recibirá un identificador único independiente del nombre visible y de su ruta de archivo.

Las futuras definiciones de mundo enumerarán sus niveles, sus dependencias de desbloqueo y la referencia al jefe. Ningún nivel concreto está definido todavía.

El guardado distinguirá `unlocked`, `completed` y los mejores resultados. Completar un nivel no lo bloqueará: el mapa permitirá volver a cualquier nivel desbloqueado. Rejugarlo conservará los desbloqueos y solo sustituirá un mejor resultado cuando corresponda.

El progreso se guardará bajo `user://` con una versión de esquema, escritura a un archivo temporal antes de reemplazar el principal y tratamiento de archivos ausentes o inválidos. Los ajustes de accesibilidad y controles se almacenarán separados del progreso. No guardar partidas dentro de `res://`.

## Presentación y rendimiento

- Vista lateral y física 2D. Usar nodos `Node2D`, `CharacterBody2D`, `Area2D`, `TileMapLayer`, `Camera2D` y `Control` según la responsabilidad.
- Resolución lógica inicial de 1280 × 720, escalado `canvas_items` y aspecto `expand`. La cámara, límites y UI deberán adaptarse al área visible adicional en otras proporciones.
- Orientación horizontal en móvil. Los futuros controles táctiles respetarán los recortes y la zona segura del dispositivo.
- Objetivo de 60 FPS a validar en dispositivos reales; física configurada a 60 pasos por segundo. Es un objetivo, no una medición de esta base vacía.
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

Esta entrega añade el skill y su documentación. La escena principal continúa vacía; las imágenes, animaciones y escenas de personaje se crearán solo cuando se encargue ese contenido.

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

Solo están definidos los nombres. Cada escena futura deberá declarar sus capas y máscaras de forma explícita.

## Accesibilidad prevista

Las acciones iniciales incluyen teclado y mando. Al crear la interfaz se añadirán navegación con foco visible, textos escalables y legibles, controles reasignables y botones táctiles ajustables. Las señales relevantes combinarán forma, texto o sonido para evitar depender únicamente del color. Se preverán opciones para reducir sacudidas y destellos, además de pausa accesible y volúmenes separados.

Estas opciones requieren implementación y pruebas de uso; no están disponibles en la escena vacía.

## Referencias técnicas

- [Godot 4.7.2 estándar](https://godotengine.org/download/archive/4.7.2-stable/).
- [Comparación oficial de renderizadores](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html).
- [Exportar a Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).
- [Exportar a Windows](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).
