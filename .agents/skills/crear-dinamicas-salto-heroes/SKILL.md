---
name: crear-dinamicas-salto-heroes
description: Diseñar, ampliar y revisar dinámicas jugables, recorridos, llaves, puertas, puntos de control y progresión de niveles de Salto Heroes / Juego Diego para un niño de 10 años. Usar al crear mecánicas, planificar tres niveles antes de cada jefe, dimensionar recorridos de al menos 15 minutos o preparar su integración en Godot 2D para Android y Windows. Contrastar el prototipo y generar fichas verificables; integrar jugabilidad solo cuando el encargo lo incluya. No sustituye el skill de personajes.
---

# Crear dinámicas de Salto Heroes

## Preparar el encargo

1. Localizar el proyecto indicado por el usuario. En una copia dentro de `.agents/skills/`, subir tres directorios y comprobar `project.godot` y `docs/ARQUITECTURA.md`. Si el skill está instalado fuera del proyecto, usar la ruta suministrada o el repositorio `RamonC5/juegoDiego` mediante GitHub; no asumir una ruta de otra sesión.
2. Leer `AGENTS.md`, la arquitectura y [las reglas y el ritmo](references/reglas-y-ritmo.md). Separar creación del skill, diseño, implementación y pruebas. Una petición de skill o diseño autoriza documentación y plantillas; desarrollar niveles requiere que el encargo incluya integración.
3. Consultar [el inventario verificado](references/estado-prototipo.md) y contrastarlo con los archivos actuales antes de basar un reto en una capacidad. Registrar rama/commit, rutas y diferencias. Si no se puede acceder al proyecto, identificar el inventario como una instantánea y marcar la verificación actual como pendiente.
4. Distinguir requisitos del usuario, hechos implementados, propuestas y decisiones abiertas. Dar prioridad a las instrucciones actuales. No convertir estimaciones de duración ni conceptos gráficos en jugabilidad comprobada.
5. Reutilizar identificadores y consultar `docs/DINAMICAS.md`, fichas existentes y [el catálogo](references/catalogo-dinamicas.md). Mantener ocho mundos, niveles rejugables, arte raster 2D HD y controles por gestos.

## Diseñar una dinámica

1. Copiar [la plantilla de dinámica](assets/dinamica.template.json). Seguir [el contrato JSON](references/contrato-json.md); usar Python 3 sin dependencias adicionales para comprobarlo.
2. Definir objetivo, acción del jugador, recompensa, reglas de éxito/fallo, señales y recuperación. Identificar dependencias implementadas o nuevas y sus fuentes. Clasificar la ficha completa como `implementada` solo cuando existan integración y evidencia; una combinación nueva de piezas existentes sigue siendo propuesta o ampliación.
3. Enseñar en un tramo seguro, practicar con variaciones y combinar después. Aprovechar los gestos conocidos; resolver expresamente cualquier conflicto entre coger/lanzar e interactuar. Reservar las cadenas de precisión difíciles para recompensas opcionales.
4. Especificar qué ocurre al caer, morir, perder un objeto necesario, pausar, cerrar el juego y rejugar. Asegurar reposición o recuperación para toda herramienta obligatoria. No dar por existente el guardado de intentos a mitad de nivel.
5. Describir señales por forma, postura, animación o texto además de color y sonido, lectura en móvil y ajustes de control. Mantener al enemigo normal eliminable por pisotón y al jefe vulnerable a objetos lanzados.
6. Comparar con [el ejemplo del puente](assets/ejemplo-dinamica-puente.json) para distinguir la recogida/lanzamiento existente de la conexión nueva entre una diana y un puente. No copiar ese ejemplo como única estructura para todas las dinámicas.

## Componer un nivel o un mundo

1. Copiar [la plantilla de nivel](assets/nivel.template.json). Para una aventura, distribuir exactamente tres llaves diferentes en tres retos principales; conservar su recogida automática y las manos libres. Dejar hojas, cristales y secretos como opcionales.
2. Crear segmentos ordenados con propósito, dinámica, intervalo de tiempo exclusivo y recompensa. Consultar [el ejemplo del bosque](assets/ejemplo-nivel-bosque.json). Evitar sumar dos veces segmentos simultáneos, rutas alternativas o tiempos de una dinámica ya incluidos en su segmento.
3. Dimensionar por defecto la primera partida normal para un mínimo de 15 minutos de ruta principal y un objetivo de 18–22. **Excepción:** si el usuario solicita explícitamente una duración inferior, prevalece su encargo; registrar solicitud, fecha, nuevo intervalo y alcance en `duracion.excepcion_duracion_usuario`, sin atribuir tiempo medido. Añadir variedad y decisiones, sin rellenar el tiempo con esperas, largos corredores, secretos obligatorios ni derrotas.
4. Introducir como punto de partida una o dos dinámicas obligatorias nuevas por nivel. Alternar exploración, plataformas, combate, pequeños rompecabezas y descansos. Situar faroles aproximadamente cada 3–4 minutos y antes de retos relevantes; justificar las excepciones.
5. Planificar tres aventuras por mundo y después su jefe. Conservar identificadores `world_01`–`world_08`. Exigir completar las tres aventuras para desbloquear el jefe; separar la condición de derrotarlo de la puerta de tres llaves. No exigir 15 minutos al encuentro con el jefe por herencia de la regla de las aventuras.
6. Diseñar el retorno para buscar una llave pendiente y evitar salidas que hagan inaccesible un objetivo obligatorio. Conservar los desbloqueos y mejores resultados al rejugar. Mantener como propuestas los nombres y ambientes futuros que no haya elegido el usuario.

## Verificar y entregar

1. Guardar las fichas solicitadas en `docs/dinamicas/<id>.json` y los recorridos en `docs/niveles/<id>.json`, salvo otra ubicación del usuario. Enlazarlos desde `docs/DINAMICAS.md`. No mezclar el material de autoría con escenas ejecutables.
2. Ejecutar, desde la raíz del proyecto:

   ```sh
   python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py docs/dinamicas/mi_dinamica.json docs/niveles/world_01_level_01.json
   ```

   Para comprobar las tres aventuras y su jefe de un mismo mundo, pasar sus cuatro fichas de nivel y añadir `--mundo`. Las plantillas sin completar deben fallar. Los ejemplos completos deben pasar.
3. Interpretar un resultado correcto como consistencia documental. El comprobador revisa campos, ranuras, segmentos, presupuestos de tiempo, dependencias declaradas y muestras; no prueba alcanzabilidad física, diversión, tacto ni rendimiento. No declararlos verificados por pasar el script.
4. Comprobar jugando el recorrido principal con el perfil objetivo, descontando pausas, cargas, secretos y repeticiones por derrota. Guardar muestras anónimas y distinguir `estimada` de `medida`. Si una primera partida queda por debajo de 15 minutos, revisar contenido y volver a medir; no bloquear la salida por reloj. Una rejugada experta puede ser más corta.
5. Si se solicita implementación, respetar componentes, señales, datos `.tres`, colisiones y progreso de la arquitectura. Leer código y pruebas relevantes; integrar solo el alcance solicitado. Usar `generar-personajes-salto-heroes` para arte de personajes. Añadir pruebas de recuperación, duplicación, pausa, guardado y salida cuando cambien esas reglas; comprobar tacto y rendimiento en Android y Windows físicos cuando estén disponibles.
6. Al mantener este skill, validar su frontmatter con el comprobador de skill-creator, revisar enlaces y metadatos y ejecutar los ejemplos y casos negativos con `python3 -m unittest discover -s .agents/skills/crear-dinamicas-salto-heroes/scripts -p 'test_*.py'`. Probar un encargo representativo antes de guardarlo. Sincronizar los cambios con el Git que respalda el skill; informar de la subida realmente confirmada y de cualquier comprobación pendiente.
7. Entregar inventario utilizado, fichas, duración estimada o medida, trabajo nuevo necesario y evidencia de validación. Mantener separadas las afirmaciones de diseño, implementación y prueba.
