# Salto Heroes · Juego Diego

Juego de plataformas **2D HD** para **Android y Windows**, con ocho mundos previstos y niveles rejugables.

## Bosque Esmeralda 1-1 · versión 0.2.0

El juego abre **El despertar del bosque**, el primer nivel del Bosque Esmeralda. Incluye fondo raster con parallax, suelo con musgo, árboles, helechos, plataformas opcionales, cuatro brechas, siete patrullas de Terrón y Moflete, objetos arrojadizos, hojas doradas, tres cristales, farol de control y arco de salida.

Diego mantiene sus movimientos, 13 estados de animación y controles por gestos sin botones fijos. Los enemigos se eliminan saltando encima y reciben impactos de objetos lanzados. La meta guarda el resultado y permite rejugar para mejorar tiempo y coleccionables. Desde Pausa puedes volver al entrenamiento anterior, con los seis objetos, o regresar al bosque.

![Bosque Esmeralda con árboles de musgo y luz entre la vegetación](game/assets/textures/environments/bosque_esmeralda/forest_backdrop_v001.png)

[Diseño del nivel, recorrido y controles](docs/BOSQUE_ESMERALDA.md).

## Descargar el APK e instalarlo

1. Abre [Actions → Validar y generar APK Android](https://github.com/RamonC5/juegoDiego/actions/workflows/validate.yml) y entra en la ejecución verde del commit más reciente.
2. Descarga el artefacto `salto-heroes-android-<número>`, descomprime el ZIP y abre `salto-heroes.apk` en el móvil Android ARM64.
3. Si Android lo solicita, permite instalar aplicaciones desde el navegador o gestor de archivos utilizado.

El APK es una compilación de pruebas firmada, con versión y commit en `build-info.json`, y se conserva durante 30 días. La CI comprueba su firma, paquete y arquitectura. Las capturas de la escena real se descargan en `bosque-esmeralda-capturas-<número>`. Las claves y binarios no se incluyen en Git.

## Jugar y abrir el proyecto

- **Táctil:** arrastra horizontalmente en la mitad de movimiento; desliza hacia arriba en la otra mitad para saltar y toca brevemente para coger o lanzar. Admite varios dedos a la vez.
- **Teclado:** A/D o flechas, Espacio, E y Escape. También admite mando.
- **Pausa:** sensibilidad, lados intercambiables, salto completo, carrera, guías y teclas reasignables. Foco visible y textos de energía y coleccionables.

Importa `project.godot` con **Godot 4.7.2 estándar** y pulsa F5. Usa GDScript tipado, renderizador Compatibility, vista base 1280×720, orientación horizontal y física a 60 Hz. Los perfiles de exportación son Android ARM64 y Windows x86_64.

## Verificación

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 3
godot --headless --fixed-fps 60 --path . --script tools/tests/test_player.gd
godot --headless --fixed-fps 60 --path . --script tools/tests/test_throwables.gd
godot --headless --fixed-fps 60 --path . --script tools/tests/test_forest.gd
```

148 comprobaciones: 55 de protagonista y controles, 63 de objetos y 30 de nivel. Incluyen un recorrido completo con movimiento y saltos reales, checkpoint, caída, pisotones, lanzamientos y guardado rejugable. `capture_forest.gd` captura móvil, tablet y panorámico con renderizado Compatibility real. El objetivo de 60 FPS y el tacto deben comprobarse también en dispositivos físicos.

## Estructura y documentación

| Ruta | Contenido |
| --- | --- |
| `game/boot/` | Composición del nivel y base del entrenamiento, pausa y opciones |
| `game/features/levels/` | Construcción del bosque, terreno, coleccionables y fondo |
| `game/features/enemies/` | Patrullas de Terrón y Moflete y contratos de combate |
| `game/features/player/` | Diego, animaciones, entrada y entrenamiento |
| `game/features/objects/` | Seis arrojadizos y sus definiciones |
| `game/core/services/` | Ajustes y progreso local separado |
| `game/data/worlds/world_01/level_01.tres` | Datos del primer nivel; quedan reservados los otros mundos |
| `game/assets/` | Recursos finales usados por el juego |
| `art/` | Conceptos, fichas, prompts y revisión; excluidos del APK |

- [Arquitectura](docs/ARQUITECTURA.md).
- [Desarrollo y exportación Android](docs/DESARROLLO.md).
- [Catálogo de personajes](docs/PERSONAJES.md).
- [Protagonista y animaciones](docs/PROTAGONISTA.md).
- [Gestos táctiles](docs/CONTROLES_TACTILES.md).
- [Objetos arrojadizos](docs/OBJETOS_ARROJADIZOS.md).
- [Skill de personajes](.agents/skills/generar-personajes-salto-heroes/SKILL.md).

Los otros cuatro enemigos conservan sus conceptos. Las animaciones de Terrón y Moflete usan transformaciones de sus sprites existentes; no son hojas de fotogramas nuevas. Los otros niveles, mundos, jefes y audio quedan para entregas posteriores.
