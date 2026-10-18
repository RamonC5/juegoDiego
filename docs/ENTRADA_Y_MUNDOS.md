# Entrada y mapa de Super Diego · 0.11.0

La aplicación abre ocho escenas laterales de aventura de cuatro segundos cada una. El fondo ocupa la pantalla y muestra caminos cercanos, vegetación, mar, ruinas, nieve, cristales, manglares, nubes y lava; no utiliza la ilustración del mapa. Un degradado oscuro protege la lectura del título y los controles. «Jugar ahora» está disponible desde el primer momento y abre el mapa completo.

Diego utiliza ocho poses nuevas de carrera únicamente en la entrada. Los fotogramas siguen la distancia recorrida y una zancada de 132 unidades de referencia; el reloj no mantiene una carrera rápida mientras el cuerpo apenas avanza. Se elimina la superposición de dos dibujos que duplicaba manos y botas. Los recortes tienen lienzo virtual 1024 × 1024 y una raíz común por fila, sin recentrar cada silueta.

Los saltos usan parábolas con preparación y recuperación breves. El doble salto conserva la posición al añadir el segundo impulso. Lanzar incluye frenada continua y trayectoria independiente de la vasija; termina volviendo a correr. El resbalón dura 0,34 segundos. Ya no se mantiene una pose no cíclica durante la mayor parte de una escena. La liana sigue anclada a las manos y gira alrededor de su agarre.

Moflete persigue a Diego en el bosque; Nóctilo cruza cuevas, pantano y cielo con aleteo articulado. Reutilizan `EnemyVisual` y sus perfiles, con materiales propios, brazos/manos/pies y alas/puntas. Son actores de la presentación: no crean colisiones, daño ni niveles nuevos. La opción de movimiento reducido los oculta y congela los adornos.

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

El mapa conserva su WebP original. Las escenas nuevas y la carrera se generan con image_gen integrada; el PNG de carrera se conserva intacto y se integra mediante recortes explícitos. [Prompts y procedencia](../art/entrance/prompts.md) · [Validación y límites](pruebas/entrada-0.11.0.md).

