# Entrada y mapa de Super Diego · 0.9.0

La aplicación abre una presentación de Diego corriendo, saltando, transportando una vasija, resbalando, lanzando, balanceándose en una liana y celebrando. Cada una de las ocho aventuras dura 3,2 segundos y el conjunto se repite. Se usan las poses raster existentes. «Jugar ahora» está disponible desde el primer momento y abre el mapa completo.

| ID | Nombre del avance visual | Acceso |
| --- | --- | --- |
| world_01 | Bosque Esmeralda | Disponible: nivel 1-1 existente |
| world_02 | Costa de Coral | Bloqueado |
| world_03 | Ruinas del Sol | Bloqueado |
| world_04 | Cumbres de Hielo | Bloqueado |
| world_05 | Cuevas de Cristal | Bloqueado |
| world_06 | Pantano de Raíces | Bloqueado |
| world_07 | Islas del Cielo | Bloqueado |
| world_08 | Volcán de Obsidiana | Bloqueado |

Los siete nombres y ambientes pendientes son propuestas visuales editables basadas en el catálogo de llaves; no equivalen a niveles desarrollados ni fijan su futuro diseño. El bosque abre directamente al tocarlo. Los demás muestran candado y texto BLOQUEADO; tocarlos conserva el mapa y comunica su estado. WorldCatalog valida también las rutas y rechaza IDs desconocidos. Completar el bosque no desbloquea los otros mundos todavía.

El menú de pausa del bosque incorpora «Mapa de mundos» y distribuye sus acciones en dos columnas. Salir termina el intento: volver al bosque inicia otro recorrido. La colección, ropa y mejores resultados mantienen los guardados anteriores. El entrenamiento conserva su acceso.

Botones de al menos 52 px, foco contrastado, nombres accesibles, zona segura Android y navegación por toque, ratón, teclado y mando. El estado no depende del color ni del audio. El control «Movimiento reducido» congela la presentación y el pulso del mapa y guarda la preferencia sin borrar los demás ajustes. «Inicio» o Atrás/Escape vuelve del mapa a la entrada. El texto y los candados se dibujan como UI, separados de la ilustración.

`test_entrance.gd` verifica el flujo real, los siete bloqueos, poses, movimiento reducido, foco, tamaños táctiles y retorno desde pausa. `capture_entrance.gd` produce vistas Compatibility de móvil y tablet. La prueba del APK navega con toques reales por entrada, mapa y una isla bloqueada antes de jugar al bosque. La validación en los dispositivos físicos del usuario sigue pendiente.

Arte nuevo generado con image_gen integrada, sin referencias externas, convertido a WebP calidad 88. No se crean ni modifican sprites del protagonista. [Prompt](../art/entrance/prompts.md).
