# Bosque 1-2 · Las copas del bosque

El recorrido principal amplía Bosque Esmeralda con setas elásticas, ascensos a las copas, troncos viajeros, puentes y tres barrancos de lianas. Se conserva el nivel 1 y su colección. El secreto elegido por el usuario sube a las copas por una liana y vuelve al camino por ramas.

Hay 16 tramos, 58 patrullas de Terrón/Moflete, cuatro setas, cuatro troncos, cinco puentes, tres cruces de cinco lianas y 16 portones de dos dianas. Las piñas se reponen. Las escaleras, el suelo de recuperación y los portones abiertos permiten volver a buscar objetivos pendientes. Se mantienen doble salto, lanzamiento aéreo y trepa manual.

Las setas reutilizan un recorte del atlas raster del bosque. Aterrizar desde arriba impulsa a 1040 px/s; su compresión dura 0,45 segundos y permite un salto aéreo de corrección. La primera se enseña sobre suelo continuo. No cambian las capacidades de Diego ni el recurso del primer nivel.

| Objetivo | Posición | Regla |
| --- | --- | --- |
| Llave 1 | (19100, 550) | Tras La primera copa |
| Llave 2 | (43100, 550) | Tras La segunda copa |
| Llave 3 | (71900, 550) | Tras La tercera copa |
| Farol 1 | (19320, 600) | Guarda reaparición, sin curar |
| Farol 2 | (38520, 600) | Guarda reaparición, sin curar |
| Farol 3 | (57720, 600) | Guarda reaparición, sin curar |
| Cristales intermedios | (18490, 145), (42490, 145), (71290, 145) | Desvíos opcionales desde terrazas, con retorno |
| Salida | (76620, 600) | Solo requiere las tres llaves |

El mapa abre una selección de aventuras. Completar Bosque 1-1 desbloquea 1-2 usando el resultado existente en `progress.json`, esquema 1. La pantalla final del primero permite continuar directamente. La colección por nivel, las hojas acumuladas para ropa y el ayudante obtenido se conservan. Los tres fragmentos de Luci siguen estando en 1-1; no se duplican en la segunda aventura. El nivel 3 y el jefe siguen pendientes.

El presupuesto es de **18–22 minutos estimados**, excluyendo secretos, pausas y repeticiones. La ruta automática protegida tarda 500,6 segundos simulados, con enemigos aislados: acredita geometría y acciones, no duración humana, dificultad infantil ni diversión. Faltan partidas de observación.

## Sendero secreto sobre los árboles

Elección del usuario el 19-10-2026: «Quiero que suba por una liana y vaya por encima de los arboles como recorrido secreto». Sustituye la propuesta subterránea pendiente. La posición concreta y el trazado son decisiones de autoría dentro de esa elección.

Tras el primer farol, el tótem en (19510,600) señala la liana de x=19660. Diego salta para agarrarse y mantiene ARRIBA —arrastre ascendente, W/↑ o mando— para trepar sus 800 px. El balanceo es suave; no hay ascenso automático. Otro salto lleva a la primera copa, a y=-60. Cinco robles completos con copas raster transparentes sostienen ramas anchas con huecos de 100 px y alturas próximas. El suelo del camino sigue debajo para recuperar una caída.

Hay 21 hojas nuevas con IDs independientes y un brote al final, que amplía la energía a cuatro corazones una vez por intento. Reentrar no cura otra vez; morir conserva el máximo y la recompensa. Rejugar repone el brote; las hojas siguen guardadas. Tres ramas escalonadas devuelven al suelo en x=23430, antes del portón. No se teletransporta a Diego ni se omite el portón obligatorio. La ruta principal y sus tres llaves se completan sin visitar las copas.

El recurso conserva `secret_grove = Vector2(-1,-1)` y activa `canopy_secret = Vector2(19660,600)`. No se mueven coleccionables previos ni cambian sus IDs. El guardia que patrullaba junto a la entrada espera ahora en x=21100, después de la seta; se mantienen 58 enemigos. Una rama decorativa del primer árbol sostiene el anclaje de la liana. Luci puede orientar hacia el acceso, pero el tótem y la pista accesible funcionan sin tener el ayudante.

[Ficha verificable del nivel](niveles/world_01_level_02.json) · [Setas elásticas](dinamicas/setas_elasticas.json) · [Pruebas y límites](pruebas/bosque-1-2.md).
