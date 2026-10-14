---
name: generar-personajes-salto-heroes
description: Diseñar, generar, editar y verificar personajes originales y sprites animados de Salto Heroes / Juego Diego mediante image_gen para Godot 2D, Android y Windows. Usar para protagonistas, enemigos eliminables por pisotón, jefes vulnerables a objetos lanzados, fichas de personaje, poses y hojas de animación del proyecto. También usar al mantener este flujo de creación. No usar para mascotas de ChatGPT, modelos 3D, escenarios completos ni implementación de jugabilidad.
---

# Generar personajes de Salto Heroes

## Preparar el encargo

1. Localizar la raíz del proyecto: desde esta carpeta, subir tres directorios. Leer `docs/ARQUITECTURA.md`, `project.godot` y [los requisitos](references/requisitos.md).
2. Distinguir el trabajo solicitado: mantener el skill, preparar una especificación, generar un concepto, producir sprites o integrar recursos. Para tareas de skill, arquitectura o especificación, no generar imágenes ni añadir contenido al juego.
3. Leer [el contrato de producción](references/produccion-godot.md) para sprites, animaciones o integración; consultar [procedencia y alcance de la base](references/fuentes.md) al mantener el skill.
4. Completar [la plantilla de encargo](assets/brief.template.yaml) con los datos del usuario. Reutilizar la ficha y las referencias existentes si se modifica un personaje. Separar requisitos confirmados de propuestas.
5. Mantener ocho mundos y niveles rejugables como contexto; crear únicamente los personajes y acciones pedidos. No inventar ocho protagonistas, temáticas de mundos ni plantillas completas de enemigos.
6. Si falta la definición visual de «opción A», conservar las restricciones conocidas y marcar la propuesta como provisional. Pedir únicamente un dato que impida cumplir el encargo; no convertir preferencias pendientes en decisiones definitivas.

## Fijar la identidad visual

- Resolver el acabado con sprites raster 2D de alta resolución, texturas legibles y sombreado suave. Evitar apariencia de boceto, dibujo plano o cómic; no sustituir el encargo por modelos, escenas ni renders 3D.
- Tratar New Super Mario Bros. U y Donkey Kong Country Returns como referencias de acabado y claridad del movimiento. Diseñar identidad propia, sin reutilizar sus personajes ni recursos como entregables.
- Fijar silueta, proporciones, materiales, paleta, vestuario, cámara lateral y luz de referencia en la ficha. No añadir una especie, nombre, accesorio o historia como si estuviera confirmado.
- Diferenciar los roles mediante silueta y postura, además del color. Hacer legibles la parte pisable de un enemigo y la vulnerabilidad de un jefe según su diseño, sin cambiar las reglas del juego.
- Mantener manos, pies y objetos legibles en movimiento y a tamaño móvil. Evitar destellos o señales que dependan solo del color.

## Generar o editar

1. Leer y seguir el skill `imagegen` disponible en la sesión. Utilizar la herramienta integrada `image_gen` para generar y editar arte. No dibujar personajes con Python, SVG, CSS, canvas ni primitivas como sustitución.
2. Distinguir imagen de referencia e imagen que debe editarse. Inspeccionar primero cualquier imagen local con `view_image`; utilizar los parámetros de referencia que admita la herramienta disponible, sin inventar rutas de salida, modelos, seeds ni argumentos.
3. Preparar un prompt con: objetivo, rol, identidad, referencia visual, acabado 2D, cámara lateral fija, pose o secuencia, encuadre completo, escala, iluminación, transparencia y restricciones de continuidad. Conservar el prompt exacto y la relación de referencias.
4. Solicitar transparencia real mediante `transparent_background: true` para sprites aislados. Evitar tablero de ajedrez dibujado, fondo de color, suelo, sombra proyectada fuera del personaje, texto, etiquetas y marcas de agua.
5. Crear primero una referencia base por personaje cuando no exista. Reutilizarla en las llamadas de poses y animaciones para conservar identidad. Considerar un diseño aprobado solo si el usuario ya lo eligió; identificar las nuevas decisiones como propuestas sin detener un encargo autorizado.
6. Generar una acción por lote pequeño, con número y orden de fotogramas explícitos. Conservar escala, celda, raíz, cámara y apariencia; cambiar únicamente la pose o estado solicitado. Hacer llamadas separadas para activos distintos.
7. Inspeccionar cada resultado. Repetir una corrección concreta si aparecen recortes, variaciones de identidad, manos adicionales, pérdida de transparencia o acciones ilegibles. No presentar una colección de poses repetidas como una animación completa.
8. Si no está disponible `image_gen`, entregar el encargo y los prompts preparados y explicar la limitación. No instalar proveedores ni cambiar a una API de pago automáticamente. Usar CLI solo cuando el usuario lo pida expresamente y siguiendo `imagegen`.

## Verificar y entregar

1. Para archivos disponibles localmente, ejecutar la comprobación de lectura del PNG:

   ```sh
   python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py ruta/al/sprite.png
   ```

   Para una hoja de seis fotogramas en celdas de 256 × 256:

   ```sh
   python .agents/skills/generar-personajes-salto-heroes/scripts/validate_sprite.py ruta/a/run.png --frame-width 256 --frame-height 256 --frames 6
   ```

   Requerir Python y Pillow para este comprobador. Si falta Pillow, comunicarlo o instalarlo dentro de un entorno de desarrollo permitido; no añadirlo como dependencia del juego. No usar el comprobador para modificar imágenes.
2. Revisar visualmente secuencia, continuidad, raíz estable y lectura sobre fondos claros y oscuros. Registrar lo verificado y lo pendiente. El comprobador detecta dimensiones, alfa, recortes y celdas vacías; no certifica identidad, fluidez ni animación correcta.
3. Si se piden únicamente conceptos, devolver las imágenes y su ficha. No integrarlas en el proyecto. Para recursos destinados al juego, copiar únicamente los finales a `game/assets/textures/characters/<id>/`; conservar encargos, prompts y evidencias en `art/characters/<id>/` con `art/.gdignore`. No dejar rutas de ejecución apuntando a archivos temporales o de otra conversación.
4. Registrar `character.json` según el contrato de producción, con dimensiones y resultados reales. No declarar un recurso listo si quedan controles obligatorios pendientes. No sobrescribir versiones existentes salvo petición expresa.
5. Crear o modificar `SpriteFrames`, escenas y referencias de juego únicamente si el encargo incluye integración. Mantener colisiones y reglas de daño separadas del dibujo; no generar implementaciones de combate por inferirlas del arte.
6. Informar del resultado, archivos creados, prompts utilizados y limitaciones. Distinguir concepto, sprite verificado e integración comprobada. Para una petición de solo skill o arquitectura, mantener vacía la escena de arranque.
