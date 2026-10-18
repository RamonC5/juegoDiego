# Reglas y ritmo de diseño

## Requisitos del proyecto

- Conservar plataformas laterales 2D HD, Android y Windows, ocho mundos y niveles rejugables.
- Mantener acabado raster pulido, materiales legibles y sombreado suave. Consultar el arte existente; no reconstruir una «opción A» cuya definición detallada no esté disponible.
- Diseñar para un niño de 10 años, con retos comprensibles y dificultad ajustable mediante pruebas.
- Planificar tres niveles de aventura antes del jefe de cada mundo: 24 aventuras y ocho encuentros. La ampliación todavía no está implementada.
- Exigir tres llaves distintas por aventura. Mantener recogida automática, manos libres, contador, ranuras numeradas y aspecto coherente con el ambiente. Separar las llaves de cada nivel y reponerlas al rejugar.
- Conservar enemigos normales eliminables por pisotón y jefes atacados con objetos lanzados. Enseñar las acciones necesarias antes del jefe; ofrecer reposición de munición y reintento del combate.
- Mantener hojas, cristales, fragmentos y secretos opcionales. No condicionar salida ni trajes a la colección completa. Aplicar las decisiones de `secretos-y-coleccion.md`: consulta de ubicación/actividad antes de implementar, tótem por acceso y colección intermedia en nivel 2 y máxima en nivel 3.

## Duración

Exigir por defecto al menos 15 minutos de ruta principal en primera partida normal del perfil objetivo. **Si existe petición posterior explícita de acortar un nivel**, documentar la excepción con fecha y texto del encargo y recalcular segmentos, sin imponer el mínimo anterior. Usar como presupuesto inicial 18–22 minutos para futuras aventuras. Conservar la excepción ya vigente de Bosque 1-1: 9,2–10,94 minutos estimados (17-10-2026); no volver a exigirle 15 minutos. El encuentro con el jefe es separado y no hereda automáticamente ese mínimo.

Definir tiempos exclusivos por segmento ordenado. Sumar solo los segmentos principales y contar una sola vez acciones simultáneas. No sumar a esa duración las fichas individuales de dinámicas ya incluidas, rutas opcionales ni alternativas mutuamente excluyentes. Para una bifurcación obligatoria, presupuestar el recorrido válido más corto y comprobarlo jugando.

Excluir de la medida pausas, cargas, cinemáticas, búsquedas opcionales y repeticiones por derrota. No convertir esperas, bloqueos de reloj o un largo pasillo vacío en contenido para alcanzar el mínimo. Añadir situaciones y decisiones variadas cuando falte duración.

Planificar partidas de observación con el perfil objetivo. Registrar identificadores anónimos, duración del recorrido principal y exclusiones; no inventar muestras ni dar por medido un presupuesto. El mínimo deberá cumplirse en las muestras registradas y revisarse si nuevas pruebas lo contradicen. No garantizar el mismo tiempo para cualquier jugador; una rejugada o recorrido experto puede ser más breve.

## Dificultad y controles

Tomar estos valores como decisiones de diseño iniciales ajustables, no como conclusiones sobre todos los niños de esa edad:

- Introducir una o dos dinámicas obligatorias nuevas por nivel. Empezar con explicación visual y práctica segura, añadir variaciones y combinar después.
- Alternar exploración, saltos, combate y pequeños rompecabezas. Incorporar espacios de descanso, anticipación visible y rutas de recuperación.
- Situar faroles aproximadamente cada 3–4 minutos y antes de desafíos importantes. Usar un límite estimado inicial de cuatro minutos entre puntos seguros y documentar cualquier cambio de criterio.
- Evitar cadenas obligatorias de muchos saltos precisos, saltos ciegos y peligros que dependen de reaccionar a algo fuera de pantalla. Reservar maestría y atajos para objetivos opcionales.
- Reutilizar pulsación izquierda para salto y segunda pulsación aérea para doble salto; derecha para arrastre, agacharse y toque corto de coger/lanzar, con mitades intercambiables. Mantener avance agachado, salida bajo techo sólido y ponerse de pie bajo plataformas atravesables. Identificar un contexto inequívoco si una interacción comparte gesto con recoger o lanzar. Mantener teclado y mando equivalentes.
- Diseñar pistas progresivas: señalar el elemento, demostrar su relación y orientar al objetivo. Proponer su activación y temporización como sistema nuevo donde todavía no exista.

## Recuperación y persistencia

- Al morir, conservar llaves del intento y reconstruir lo resuelto antes del farol. Rearmar únicamente el tramo posterior: puentes, portones, sus dianas y piñas, enemigos y ciclos. Vincular dianas a la posición del mecanismo y comprobar retorno sin bloqueos; no usar el reinicio global histórico.
- Definir reposición y límites de recuperación de cada objeto imprescindible. Evitar que un objeto perdido deje sin solución el nivel.
- Mantener accesible una llave pendiente. Abrir un retorno, un acceso alternativo o un reinicio local cuando un tramo se cierre.
- Al rejugar o reiniciar voluntariamente, reponer las tres llaves y mecanismos del intento; conservar desbloqueos y mejores resultados.
- Conservar colección y equipo en `collection.json` al morir, reiniciar y cerrar; escritura segura, manifiesto y IDs sin duplicados. La vida secreta se conserva durante el intento. El cierre reinicia posición, llaves y mecanismos; guardado del intento sigue como propuesta. Los mejores resultados se guardan por separado.
- Para un jefe, comprobar derrota, reposición de objetos y repetición del combate sin repetir las tres aventuras completadas.

## Accesibilidad y presentación

- Mantener el escenario sin letras, flechas o iconos flotantes; combinar forma, postura y movimiento. Usar iconos y cantidades en HUD, instrucciones y textos accesibles en pausa. Ofrecer señales visuales para información sonora y señales no sonoras para objetivos esenciales.
- Mantener textos breves y legibles en móvil, foco visible, zona segura y pausa accesible. Comprobar Android, Windows táctil y formatos de pantalla distintos.
- Conservar ajustes de sensibilidad, lados, salto completo y reasignación; no introducir gestos de precisión obligatorios sin probarlos.
- Evitar destellos y sacudidas que no aportan información. Mantener colisiones y daño independientes del dibujo.
- Mantener títulos descriptivos, enlaces con propósito y texto alternativo cuando se añada documentación con imágenes. El SEO web solo aplica si el encargo incluye una página pública.

## Estilo audiovisual y aprendizaje conocido

- Mantener lianas oscilantes: salto, agarre aéreo automático, balanceo y nuevo salto para cambiar de liana. Conservar velocidad tangencial y manos en el nudo; evitar trepa automática, rigidez o bloqueos.
- Conservar persecución que puede bajar de estructuras y animación natural de brazos, manos, pies y alas según anatomía. La patrulla tranquila respeta bordes; no confundir animación de visor con IA jugable.
- Romper dianas mediante impacto lanzado válido con fragmentos de cristal irregular, respetando pausa y recuperación espacial por farol. Evitar rotura uniforme y progreso duplicado.
- Acompañar a Diego con la cámara también al caer. Dar destinos visibles y suelo de recuperación.
- Seleccionar música moderna de videojuego acorde al mundo, con volumen, silencio y pausa. No restaurar el tema ambiental sustituido ni imponer la pista del bosque a todos los mundos.
- Mantener acciones de menú de al menos 48 px, foco visible y salida fija del vestuario, con Atrás Android, Escape y mando. El arte no cambia física, colisión, daño ni saltos.
