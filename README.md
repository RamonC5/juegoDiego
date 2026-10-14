# Salto Heroes · Juego Diego

Base de un juego de plataformas **2D** para **Android y Windows**, con ocho mundos y niveles rejugables.

## Estado de esta entrega

Proyecto vacío: configuración del motor, una escena de arranque con un único `Node2D`, carpetas de trabajo y documentación técnica. Ejecutarlo abre una pantalla vacía. Las carpetas se conservan en Git mediante archivos `.gitkeep` sin contenido.

Los personajes, enemigos, jefes, niveles, menús, controles táctiles, arte, audio y sistemas de guardado se implementarán en entregas posteriores.

## Arquitectura elegida

| Elemento | Configuración |
| --- | --- |
| Motor | Godot **4.7.2**, edición estándar |
| Lenguaje previsto | GDScript con tipado estático |
| Organización | Escenas y componentes agrupados por funcionalidad |
| Renderizado | Compatibility para escritorio y móvil |
| Presentación | Escenas 2D, base de 1280 × 720, orientación horizontal |
| Física | 60 pasos por segundo |
| Plataformas de exportación | Windows x86_64 y Android ARM64 |
| Dependencias externas | Ninguna en el proyecto |

## Abrir el proyecto

1. Instala [Godot 4.7.2 estándar](https://godotengine.org/download/archive/4.7.2-stable/).
2. En el gestor de proyectos, selecciona **Importar** y abre `project.godot`.
3. Pulsa **F6** para la escena actual o **F5** para el proyecto. El resultado esperado es una pantalla vacía.

La versión del motor está fijada en [`.godot-version`](.godot-version).

## Estructura

| Ruta | Responsabilidad |
| --- | --- |
| `game/boot/` | Entrada del juego y futura composición de servicios |
| `game/core/` | Contratos, componentes y servicios compartidos |
| `game/features/` | Jugador, enemigos, jefes, objetos, niveles y mapa de mundos |
| `game/ui/` | Menús, HUD y futuros controles táctiles |
| `game/data/worlds/world_01/` a `world_08/` | Reserva vacía de los ocho mundos |
| `game/assets/` | Texturas, audio y fuentes futuros |
| `game/localization/` | Traducciones futuras |
| `.agents/skills/generar-personajes-salto-heroes/` | Skill para el futuro diseño y producción de personajes 2D |
| `docs/` | Arquitectura y guía de desarrollo |
| `tools/` | Verificación de la descarga del motor usada por CI |

## Verificación

Con el ejecutable de Godot disponible como `godot`:

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 3
```

GitHub Actions ejecuta estas comprobaciones con la versión fijada del motor. Comprueban la importación y el arranque de la base, no la jugabilidad ni la exportación a dispositivos.

## Documentación

- [Arquitectura y contratos para el desarrollo](docs/ARQUITECTURA.md).
- [Entorno, controles y exportación](docs/DESARROLLO.md).
- [Skill para generar personajes de Salto Heroes](.agents/skills/generar-personajes-salto-heroes/SKILL.md), basado en el flujo `imagegen` de OpenAI y adaptado a los requisitos del juego. Invocación: `$generar-personajes-salto-heroes`.

`export_presets.cfg` incluye los perfiles **Windows** y **Android**. Para exportar hay que instalar las plantillas de Godot y, en Android, configurar también Java y el SDK. Esta entrega no incluye ejecutables, firmas ni claves.
