# Catálogo para elegir dinámicas

Revisar el estado en el proyecto antes de reutilizar una entrada. Las propuestas no constituyen implementaciones ni fijan definitivamente nombres, mundos o personajes.

| Identificador | Idea jugable | Base existente | Trabajo necesario y recuperación |
| --- | --- | --- | --- |
| `tres_llaves_puerta` | Recorrer tres retos y abrir una puerta temática. | Llaves, ranuras, HUD y barrera en el bosque. | Repartirlas en nuevos retos; conservar acceso a pendientes y evitar duplicados. |
| `saltos_plataformas` | Explorar diferentes alturas con saltos comprensibles. | Plataformas estáticas atravesables desde abajo. | Diseñar nuevos recorridos y comprobarlos con movimiento real. |
| `pisoton_patrullas` | Leer una patrulla y saltar encima. | Terrón y Moflete integrados. | Crear encuentros variados y rutas de reintento; no cambiar la regla de pisotón por inferencia del arte. |
| `lanzamiento_objetos` | Elegir posición y momento para lanzar. | Seis objetos en entrenamiento, tres tipos en bosque. | Ajustar posiciones y reposición; comprobar impacto, consumo y recuperación. |
| `agacharse_refugio` | Leer un techo y pasar por debajo con seguridad. | Postura, avance agachado y comprobación de colisiones unilaterales integrados. | Diseñar obstáculo y salida; agacharse no concede inmunidad. |
| `puente_diana` | Golpear una diana con una piña para abrir un puente. | Conexión y rotura en cristal integradas. | Diseñar variantes y reposición; aplicar recuperación espacial por farol, sin bloquear el regreso. |
| `plataforma_movil` | Subirse, viajar y saltar hacia un destino visible. | Troncos y ascensores integrados con transporte físico. | Diseñar nuevas rutas; comprobar recuperación, cámara y bordes. |
| `seta_rebote` | Usar rebotes para alcanzar rutas altas. | Salto y rebote de pisotón como referencias. | Implementar superficie impulsora, dirección e indicación de trayectoria; ofrecer suelo de recuperación. |
| `avance_agachado` | Combinar abajo mantenido y movimiento para pasar entre raíces. | Avance/retroceso agachado integrados. | Probar techo sólido, levantarse bajo plataforma atravesable, salida, daño y conflictos de acción. |
| `placa_peso` | Llevar o lanzar una piedra a una placa que abre un paso. | Canto de río recogible y lanzable. | Crear sensor, activación y reinicio local; resolver cómo colocarla con los gestos existentes. |
| `vuelo_noctilo` | Observar un vuelo anunciado y encontrar una ocasión de pisotón. | Concepto visual de Nóctilo. | Implementar vuelo, anticipación, zona pisable alcanzable y recuperación. No presentarlo como enemigo ya jugable. |
| `gruta_hojas_vida` | Hallar entrada junto a un tótem, recorrer el subsuelo y volver mediante ascensor. | Gruta, hojas y vida integradas en Bosque 1-1. | Validar ubicación/actividad antes de cada nueva zona; conservar retorno físico y vida única por intento. |
| `lianas_dianas_barranco` | Saltar, agarrar una liana oscilante y cambiar de cuerda. | Cinco lianas móviles, agarre aéreo e impulso al soltar integrados. | Diseñar distancias alcanzables, recuperación y continuidad de manos; no restaurar trepa automática. |
| `coleccion_mundo` | Completar objetos opcionales y ver recompensas permanentes. | Colección y vestuario del bosque integrados. | Repartir accesibles/intermedios/máximos por aventuras 1/2/3 sin duplicados ni requisito de recoger todo. |
| `ruta_secretos` | Descubrir hojas, cristales o atajos. | Coleccionables opcionales del bosque. | Diseñar desvíos legibles y retorno; excluir su tiempo del mínimo obligatorio. |
| `pistas_progresivas` | Dar una orientación cada vez más concreta al atascarse. | Mensajes por posición y eventos. | Añadir detección de atasco y secuencia de pistas; mantener textos breves. |
| `guardado_intento` | Retomar una partida larga tras cerrar la aplicación. | Guardado de resultados y ajustes separados. | Serializar farol, ranuras y mecanismos por versión; restaurar un estado seguro y evitar duplicación. |
| `jefe_lanzamientos` | Aprender un patrón y aprovechar la vulnerabilidad lanzando objetos. | Contrato de impactos y dianas. | Implementar jefe, fases, señales, reposición y desbloqueo tras las tres aventuras. |

## Componer aventuras con el repertorio actual

Mantener las capacidades ya integradas como conocidas; no contar plataformas móviles o avance agachado como sistemas nuevos pendientes. Para los niveles 2 y 3 aún sin implementar, proponer una o dos novedades como setas o placas de peso y contrastar su estado antes de construirlas. No fijar nombres o ambientes de mundos futuros por este catálogo.

Incluir secretos opcionales con consulta previa y tótem. Repartir colección intermedia en el segundo nivel y máxima en el tercero. Reservar mayor exigencia para esos desvíos, con aprendizaje y recuperación adecuados a 10 años. No convertir sistemas transversales de guardado o pistas en acciones nuevas que el niño debe aprender.
