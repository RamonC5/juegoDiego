# Inventario del prototipo

Instantánea revisada el 16 de octubre de 2026 en `RamonC5/juegoDiego`, rama `main`, commit `bf72da5541bb77bfee9b4b76d0384ab30973ba32`. Contrastar con el commit actual en cada encargo. Las rutas son relativas a la raíz del juego; esta referencia no certifica futuras versiones.

| Mecánica | Evidencia en el proyecto | Alcance comprobado al leer el código |
| --- | --- | --- |
| Caminar, correr, saltar y pisar enemigos | `game/features/player/diego.gd`, `docs/PROTAGONISTA.md` | Movimiento y rebote existentes. Salto con tolerancia al borde y anticipación. |
| Agacharse | `diego.gd`: `_update_crouch`, `can_stand`, `_physics_process` | Reduce la cápsula de 98 a 58 px, conserva los pies y comprueba techo al levantarse. Frena hasta detenerse. No permite avanzar agachado ni recoger/lanzar mientras se mantiene la postura. |
| Gestos | `docs/CONTROLES_TACTILES.md`, `game/ui/touch_controls/touch_controls.gd` | Arrastre horizontal, arriba para salto, abajo mantenido para agacharse, toque corto para coger/lanzar, multitoque y lados intercambiables. |
| Arrojadizos | `docs/OBJETOS_ARROJADIZOS.md`, `game/features/objects/throwable_catalog.gd`, `game/data/worlds/world_01/level_01.tres` | Seis tipos integrados en entrenamiento. Los datos del bosque usan los índices 0, 1 y 3: barril, canto y vasija. La documentación del bosque y sus pistas mencionan piña, pero el índice 2 de piña no figura en esos puestos; tratarlo como discrepancia pendiente, sin cambiar el juego durante una tarea de skill. |
| Terrón y Moflete | `game/features/enemies/forest_enemy.gd` | Patrulla, daño lateral, pisotón y recepción de impactos lanzados. Animación por transformación del sprite. |
| Nóctilo y otros enemigos | `docs/PERSONAJES.md`, `art/characters/` | Nóctilo, Goterón, Vainete, Plumín y Remiendo son conceptos; no atribuirles comportamientos ya integrados. |
| Tres llaves | `game/features/levels/keys/level_key.gd`, `forest_stage.gd` | Tres ranuras distintas, recogida automática sin ocupar manos, una vez por llave y por intento. |
| Puerta | `game/features/levels/keys/key_exit_door.gd`, `forest_stage.gd` | Barrera física; abre con tres ranuras válidas y el nivel valida también las tres antes de finalizar una vez. |
| Identidad de llaves | `docs/LLAVES_Y_PUERTAS.md` | Ramas en bosque. Hay siete familias gráficas adicionales como propuestas, sin asignación definitiva a otros mundos. |
| Farol | `forest_stage.gd`: `_on_checkpoint`, `respawn_player` | Un punto de control en el bosque. Llaves, hojas y cristales se conservan durante el intento, incluidos los recogidos después del farol. Reiniciar repone las llaves. |
| Progreso entre sesiones | `game/core/services/level_progress.gd` | Guarda resultados de niveles completados, mejores marcas y finalizaciones; no serializa un intento a mitad de nivel. |
| Bosque 1-1 | `game/data/worlds/world_01/level_01.tres`, `level_definition.gd` | 8.200 px de ancho, cuatro huecos, once plataformas elevadas, siete patrullas, tres cristales, cinco puestos de objetos y un farol. |
| Selección de otros niveles y jefe | `docs/ARQUITECTURA.md`, `game/features/world_map/`, `game/features/bosses/` | El mapa de mundos, otros niveles y jefes siguen pendientes. |

## Precauciones de interpretación

- Tratar las pruebas automatizadas existentes como evidencia de sus casos específicos. No hay una medición registrada de 15 minutos con un niño de 10 años ni validación del tacto en sus dispositivos.
- Una diana de entrenamiento que recibe impactos no implementa un interruptor conectado a un puente. Añadir esa relación y su persistencia como trabajo nuevo.
- Varias plataformas estáticas no prueban transporte sobre una plataforma móvil; una postura agachada no prueba desplazamiento por un túnel.
- Algunas referencias antiguas describen al protagonista o sistemas como pendientes. Comparar esas afirmaciones con código y catálogos actuales, sin borrar las decisiones confirmadas del usuario.
- El plan aceptado de tres aventuras y jefe por mundo, recorridos de al menos 15 minutos y nuevas dinámicas describe desarrollo futuro. Esta entrega de skill no modifica el nivel experimental.
