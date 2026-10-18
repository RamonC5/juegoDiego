# Contrato de integración

Repositorio: `RamonC5/juegoDiego`, Godot 4.7.2 estándar, Compatibility, Android y Windows.
Leer el código del checkout actual: estas rutas son puntos de entrada, no copias inmutables.

| Responsabilidad | Ruta |
| --- | --- |
| Catálogo e identidad visual | `game/core/contracts/collection_rewards.gd` |
| Colección, desbloqueo y guardado | `game/core/services/collection_progress.gd` |
| Material independiente por instancia | `game/features/player/player_wardrobe.gd` |
| Máscaras sobre los sprites existentes | `game/features/player/wardrobe.gdshader` |
| Catálogo, prueba y equipamiento | `game/ui/menus/collection_menu.gd` |
| Aplicación real, HUD y navegación | `game/boot/main.gd` |
| Reglas vigentes | `docs/RECOMPENSAS.md` |
| Persistencia y mundo | `tools/tests/test_collection_rewards.gd` |
| Navegación y presentación | `tools/tests/test_reward_presentation.gd` |
| Capturas del juego | `tools/tests/capture_collection.gd` |

## Datos actuales

Conservar IDs: `original`, `autumn_scarf`, `fern_vest`, `forest_explorer`, `golden_forest`.
Conservar hitos: inicio, 12, 45, 100 hojas y colección completa; Luci requiere los tres fragmentos existentes.
No cambiar hitos, física o ayudante al pedir únicamente diseño.

Cada prenda incluye `id`, `name`, `description`, `leaves`, `accent`, `scarf`, `vest`, `pants` y `style`.
Usar colores hexadecimales sin almohadilla. El ID de guardado debe ser estable e independiente del nombre.
`style` selecciona el tratamiento: 0 original, 1 pañuelo, 2 añade chaleco, 3 añade pantalón, 4 conjunto dorado.
Una nueva combinación puede reutilizar un tratamiento con paleta propia. Para siluetas nuevas ampliar explícitamente
el dibujo y su soporte en todas las poses; no presentar una recoloración como una prenda con geometría nueva.

La apariencia del jugador y la vista previa deben salir de la misma definición, usando materiales distintos.
No introducir una dependencia de la posición de la entrada en el catálogo. Comprobar RGB renderizado:
un parámetro de shader cambiado no demuestra que la prenda sea visible.

## Estilo visual

Tarjetas azul noche `182a40`, superficie `102034`, texto claro `f5f8ff`, foco dorado `ffe4a0`.
Paletas de recompensa: coral `ff796f`, esmeralda `79e5ae`, glaciar `73d9ff`, oro `ffd77a`.
Conservar volumen, costuras, iluminación y textura de los PNG 2D HD de Diego, sus gafas y su rostro.
Usar la miniatura real con el mismo material; añadir nombre y estado escrito además del color.

## Recuperación y navegación

Mantener salida y acción de continuar en una cabecera fuera del ScrollContainer.
El catálogo puede desplazarse; su tamaño mínimo no puede agrandar el panel fuera de la zona segura.
Respetar el estado final y la derrota. Al continuar, limpiar dedos, gestos y teclas retenidas.
Probar toque/clic reales, Escape/Start y NOTIFICATION_WM_GO_BACK_REQUEST de Android.
No invocar únicamente el callback de cierre como prueba de que el botón se puede pulsar.

## Verificaciones

Ejecutar importación con el motor fijado, las dos suites de recompensas y las capturas Compatibility.
Revisar al menos 1280×720, 960×540 y tablet 4:3; comprobar que cabecera y botones están dentro de la zona segura.
Comparar el traje original y la recompensa a la escala de juego y en miniatura, también caminando, saltando,
agachado, cargando y en liana. Separar evidencia automática, inspección visual y pruebas físicas pendientes.
