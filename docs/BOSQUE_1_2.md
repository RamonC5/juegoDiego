# Bosque 1-2 · Las copas del bosque

El recorrido principal amplía Bosque Esmeralda con setas elásticas, ascensos a las copas, troncos viajeros, puentes y tres barrancos de lianas. Se conserva el nivel 1 y su colección. **La zona secreta de esta aventura está pendiente de validación y no está construida.**

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

## Secreto propuesto, sin implementar

Tras el primer farol, en Brotes del amanecer, se propone una entrada bajo raíces alrededor de x=21700. Un tótem de madera y musgo señalaría el acceso. Diego entraría agachado, seguiría hojas bajo tierra hasta una vida adicional por intento y volvería a la superficie en un tronco ascensor separado. Omitirla permitiría obtener las tres llaves y completar el nivel.

Se presentó también la alternativa de un refugio en las copas. **No hay una elección recibida**: la ficha conserva `validacion_usuario.estado = pendiente` y el recurso usa `secret_grove = Vector2(-1, -1)`. No se han creado el túnel, la vida ni el tótem de 1-2.

[Ficha verificable del nivel](niveles/world_01_level_02.json) · [Setas elásticas](dinamicas/setas_elasticas.json) · [Pruebas y límites](pruebas/bosque-1-2.md).
