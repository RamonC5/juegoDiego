# Salto Heroes · Juego Diego

Base de un juego de plataformas **2D** para **Android y Windows**, con ocho mundos y niveles rejugables.

## Estado de esta entrega

Primera integración jugable de **Diego**, protagonista basado en la fotografía del usuario y adaptado al acabado raster 2D del juego. Incluye diez hojas PNG, 44 poses fuente, 13 estados de animación, movimiento, salto variable, pisotón, recoger/lanzar y controles para Android y tablet Windows.

El proyecto abre una zona de entrenamiento con plataformas, una esfera recogible y dianas geométricas. El nombre y vestuario de Diego son propuestas para valorar. Se conserva el icono provisional SH.

El [catálogo de personajes](docs/PERSONAJES.md) reúne **seis enemigos normales** con ficha e imagen: Terrón, Moflete, Goterón, Vainete, Plumín y Remiendo. Son propuestas visuales 2D; sus animaciones y su integración jugable quedan pendientes. El material de autoría está en `art/`, excluido de la importación y de los APK.

El [protagonista y sus controles](docs/PROTAGONISTA.md) ya están integrados, con pausa, opciones de accesibilidad y teclas reasignables. Los ocho mundos, niveles rejugables, enemigos y jefes jugables, audio y progreso se implementarán en entregas posteriores.

## Arquitectura elegida

| Elemento | Configuración |
| --- | --- |
| Motor | Godot **4.7.2**, edición estándar |
| Lenguaje | GDScript con tipado estático |
| Organización | Escenas y componentes agrupados por funcionalidad |
| Renderizado | Compatibility para escritorio y móvil |
| Presentación | Escenas 2D, base de 1280 × 720, orientación horizontal |
| Física | 60 pasos por segundo |
| Plataformas de exportación | Windows x86_64 y Android ARM64 |
| Dependencias externas | Ninguna en el proyecto |

## Abrir el proyecto

1. Instala [Godot 4.7.2 estándar](https://godotengine.org/download/archive/4.7.2-stable/).
2. En el gestor de proyectos, selecciona **Importar** y abre `project.godot`.
3. Pulsa **F5** para abrir el entrenamiento. A/D o flechas mueven, Espacio salta y E recoge/lanza. Escape abre la pausa. También puedes usar gestos desde cualquier punto de cada mitad de la pantalla o un mando.

La versión del motor está fijada en [`.godot-version`](.godot-version).

## Estructura

| Ruta | Responsabilidad |
| --- | --- |
| `game/boot/` | Entrada del juego y futura composición de servicios |
| `game/core/` | Contratos, componentes y servicios compartidos |
| `game/features/` | Jugador, enemigos, jefes, objetos, niveles y mapa de mundos |
| `game/ui/` | Controles táctiles; HUD y pausa compuestos por la escena de arranque |
| `game/data/worlds/world_01/` a `world_08/` | Reserva vacía de los ocho mundos |
| `art/characters/` | Fichas, conceptos PNG, encargos, prompts y revisión de personajes |
| `game/assets/` | Hojas de Diego y reservas para audio y fuentes |
| `game/localization/` | Traducciones futuras |
| `.agents/skills/generar-personajes-salto-heroes/` | Skill para el futuro diseño y producción de personajes 2D |
| `docs/` | Arquitectura y guía de desarrollo |
| `tools/` | Verificación de la descarga del motor usada por CI |

## Verificación

Con el ejecutable de Godot disponible como `godot`:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 3
godot --headless --fixed-fps 60 --path . --script tools/tests/test_player.gd
```

GitHub Actions importa el proyecto, comprueba el arranque y ejecuta 55 pruebas del protagonista y los controles. Si pasan, exporta un APK de pruebas firmado para Android ARM64 y verifica firma y paquete. El renderizado se ha revisado en Godot; quedan las pruebas físicas en Android y Windows.

## Descargar e instalar el APK en el móvil

1. Abre [Actions → Validar y generar APK Android](https://github.com/RamonC5/juegoDiego/actions/workflows/validate.yml) y selecciona una ejecución terminada en verde. Debes tener acceso al repositorio e iniciar sesión en GitHub.
2. En **Artifacts**, descarga `salto-heroes-android-<número de ejecución>` y descomprime el ZIP.
3. Copia o descarga `salto-heroes.apk` en un móvil Android ARM64 y ábrelo.
4. Si Android lo solicita, permite instalar aplicaciones desde el navegador o gestor de archivos utilizado.

Cada envío a Git y cada pull request genera automáticamente un APK nuevo. Puedes solicitar otra compilación con **Run workflow**, sin modificar archivos. Los APK se conservan durante **30 días** e incluyen su checksum SHA-256 y `build-info.json` con la versión y el commit.

El APK contiene a Diego y la zona de entrenamiento. Se firma con una clave de depuración que la CI conserva en caché; consulta [la guía de CI](docs/DESARROLLO.md#integración-continua) si Android rechaza una actualización por cambio de firma.

## Documentación

- [Arquitectura y contratos para el desarrollo](docs/ARQUITECTURA.md).
- [Entorno, controles y exportación](docs/DESARROLLO.md).
- [Catálogo de personajes: ficha e imagen de cada diseño](docs/PERSONAJES.md).
- [Protagonista, animaciones, movimientos y controles](docs/PROTAGONISTA.md).
- [Skill para generar personajes de Salto Heroes](.agents/skills/generar-personajes-salto-heroes/SKILL.md), basado en el flujo `imagegen` de OpenAI y adaptado a los requisitos del juego. Invocación: `$generar-personajes-salto-heroes`.

`export_presets.cfg` incluye los perfiles **Windows** y **Android**. Para exportar hay que instalar las plantillas de Godot y, en Android, configurar también Java y el SDK. Los APK generados se descargan desde Actions; los binarios y las claves no se guardan en Git.
