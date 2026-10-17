# Catálogo para elegir dinámicas

Revisar el estado en el proyecto antes de reutilizar una entrada. Las propuestas no constituyen implementaciones ni fijan definitivamente nombres, mundos o personajes.

| Identificador | Idea jugable | Base existente | Trabajo necesario y recuperación |
| --- | --- | --- | --- |
| `tres_llaves_puerta` | Recorrer tres retos y abrir una puerta temática. | Llaves, ranuras, HUD y barrera en el bosque. | Repartirlas en nuevos retos; conservar acceso a pendientes y evitar duplicados. |
| `saltos_plataformas` | Explorar diferentes alturas con saltos comprensibles. | Plataformas estáticas atravesables desde abajo. | Diseñar nuevos recorridos y comprobarlos con movimiento real. |
| `pisoton_patrullas` | Leer una patrulla y saltar encima. | Terrón y Moflete integrados. | Crear encuentros variados y rutas de reintento; no cambiar la regla de pisotón por inferencia del arte. |
| `lanzamiento_objetos` | Elegir posición y momento para lanzar. | Seis objetos en entrenamiento, tres tipos en bosque. | Ajustar posiciones y reposición; comprobar impacto, consumo y recuperación. |
| `agacharse_refugio` | Agacharse en un lugar seguro ante un obstáculo alto. | Postura y comprobación de techo. | Implementar obstáculo y colisiones adecuados; agacharse no concede inmunidad. |
| `puente_diana` | Golpear una diana con una piña para abrir un puente. | Recoger/lanzar y receptor de impactos. | Crear diana interactiva, puente, conexión y estado persistente; reponer la piña. |
| `plataforma_movil` | Subirse, viajar y saltar hacia un destino visible. | Física y plataformas estáticas. | Crear movimiento y transporte del jugador, recuperación, cámara y pruebas de bordes. |
| `seta_rebote` | Usar rebotes para alcanzar rutas altas. | Salto y rebote de pisotón como referencias. | Implementar superficie impulsora, dirección e indicación de trayectoria; ofrecer suelo de recuperación. |
| `avance_agachado` | Combinar abajo mantenido y movimiento para pasar entre raíces. | Agacharse actualmente detiene a Diego. | Añadir velocidad, animación y reglas de avance agachado; probar techo, salida, daño y conflictos de salto/acción. |
| `placa_peso` | Llevar o lanzar una piedra a una placa que abre un paso. | Canto de río recogible y lanzable. | Crear sensor, activación y reinicio local; resolver cómo colocarla con los gestos existentes. |
| `vuelo_noctilo` | Observar un vuelo anunciado y encontrar una ocasión de pisotón. | Concepto visual de Nóctilo. | Implementar vuelo, anticipación, zona pisable alcanzable y recuperación. No presentarlo como enemigo ya jugable. |
| `gruta_hojas_vida` | Hallar una entrada de hojarasca, recoger una vida y regresar mediante ascensor. | Integrado en Bosque Esmeralda 1-1 con el gesto de agacharse y una plataforma física. | Reutilizar el patrón en otras zonas sin hacerlo obligatorio; conservar recogida única y reiniciar solo el ascensor al reaparecer. |
| `ruta_secretos` | Descubrir hojas, cristales o atajos. | Coleccionables opcionales del bosque. | Diseñar desvíos legibles y retorno; excluir su tiempo del mínimo obligatorio. |
| `pistas_progresivas` | Dar una orientación cada vez más concreta al atascarse. | Mensajes por posición y eventos. | Añadir detección de atasco y secuencia de pistas; mantener textos breves. |
| `guardado_intento` | Retomar una partida larga tras cerrar la aplicación. | Guardado de resultados y ajustes separados. | Serializar farol, ranuras y mecanismos por versión; restaurar un estado seguro y evitar duplicación. |
| `jefe_lanzamientos` | Aprender un patrón y aprovechar la vulnerabilidad lanzando objetos. | Contrato de impactos y dianas. | Implementar jefe, fases, señales, reposición y desbloqueo tras las tres aventuras. |

## Combinaciones iniciales propuestas para Bosque Esmeralda

| Nivel | Dinámicas nuevas obligatorias | Papel de las conocidas |
| --- | --- | --- |
| 1-1 ampliado | `puente_diana` | Enseñar movimiento, pisotón, recogida y lanzamiento; distribuir tres llaves en retos diferentes. |
| 1-2 | `plataforma_movil`, `seta_rebote` | Combinar alturas y exploración. Integrar Nóctilo cuando esté desarrollado; si su patrón añade una tercera dinámica obligatoria nueva, introducirlo antes de forma opcional o redistribuir el aprendizaje. |
| 1-3 | `avance_agachado`, `placa_peso` | Combinar el repertorio y practicar lanzamientos que preparan el jefe. |

Introducir sistemas transversales de pistas o guardado como mejoras del juego, sin contarlos como acciones nuevas que el niño debe aprender. Ajustar la selección si las pruebas muestran saturación o poca variedad.
