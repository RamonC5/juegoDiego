---
name: crear-recompensas-super-diego
description: "Diseñar, generar, integrar y verificar recompensas modernas de Super Diego / Juego Diego: ropa, accesorios y ayudantes, miniaturas, desbloqueos, equipamiento visible y guardado compatible. Usar cuando se pidan nuevas recompensas o revisar su estilo, visibilidad, catálogo o navegación del vestuario. No usar para mascotas de ChatGPT ni para añadir niveles o economía de pago."
---

# Crear recompensas de Super Diego

## Preparar

1. Localizar el checkout de `RamonC5/juegoDiego`; leer `AGENTS.md`, `docs/ARQUITECTURA.md`, `docs/RECOMPENSAS.md` y [el contrato de integración](references/integracion.md).
2. Revisar el catálogo y la implementación actuales antes de ampliar nada. Distinguir diseño visual, arte, nueva recompensa e integración; ejecutar únicamente el alcance pedido.
3. Fijar para cada recompensa ID estable, nombre, motivo de colección, requisito alcanzable para un niño de 10 años (sin exigir colección completa para la ropa), categoría y rareza, apariencia visible, miniatura y estados bloqueado/disponible/equipado. Reutilizar el progreso real y conservar los guardados existentes.
4. Resolver elecciones rutinarias con la identidad del juego. Pedir solo información que bloquee el encargo; no solicitar confirmaciones para integrar lo ya autorizado.

## Diseñar y producir

1. Mantener un acabado moderno, claro y coherente con el bosque y los sprites 2D HD. Conservar rostro, gafas, proporciones y animaciones de Diego. Diferenciar las prendas a escala de partida, no solo en una ilustración ampliada.
2. Usar tarjetas con miniatura real, nombre, progreso y estado escrito, acentos reconocibles y foco visible. Mantener acciones de al menos 48 px, textos legibles y navegación por tacto, ratón, teclado y mando. No depender solo del color ni añadir destellos rápidos.
3. Reutilizar el sistema de materiales para variantes de color, tejido y estampados claramente visibles en las poses reales. No describir un shader de vestuario como un personaje separado o una silueta nueva. Para nuevo arte raster, seguir `imagegen` y el skill de personajes del repositorio: generar con la herramienta integrada, inspeccionar transparencia, conservar prompts y copiar finales versionados al juego. No sustituir un sprite solicitado por primitivas o SVG.
4. Separar apariencia de física, daño, saltos y colisiones. No añadir poderes, autoequipamiento, nuevas monedas, costes, aleatoriedad ni cambios de balance por una petición visual.
5. Preparar cualquier prenda o accesorio para reposo, caminar, correr, salto, doble salto, agacharse, cargar/lanzar, derrota y liana, incluyendo espejo horizontal. Para un ayudante nuevo, aplicar su anatomía y animar alas o miembros; respetar pausa y evitar tapar aterrizajes.

## Integrar

1. Declarar datos en el catálogo, incluidos rareza e hitos de hojas acumuladas; reservar los fragmentos para Luci; aplicar un material propio por instancia en jugador, miniaturas y vista previa. Mantener un único origen de apariencia y un ID que no dependa de la posición del catálogo.
2. Mostrar todas las recompensas existentes, las etiquetas de rareza y progreso por requisito (no solo hojas). Permitir probar las pendientes sin equiparlas; permitir equipar únicamente las desbloqueadas y confirmar cuál está en uso. Hacer visible el número obtenido y la siguiente meta.
3. Conservar la colección al morir, reiniciar y cerrar. Validar recogidas por ID, no duplicarlas y guardar antes de conceder. Revertir al fallar la escritura. Mantener compatibilidad con `collection.json` y su copia válida.
4. Dejar Volver y Seguir jugando siempre visibles fuera del catálogo desplazable, también cuando haya numerosas recompensas legendarias. Soportar Atrás de Android, Escape y Start, restaurar foco y limpiar gestos al continuar. Respetar fin del nivel y reaparición.
5. Actualizar reglas, arquitectura y pruebas relevantes. Registrar apariencia realmente implementada y diferenciarla de conceptos o propuestas.

## Verificar y entregar

1. Ejecutar importación, regresión de colección y regresión de presentación/navegación. Usar el motor fijado y Compatibility.
2. Comprobar entrada/salida mediante eventos reales de clic/toque, botones del sistema y tamaños móvil/tablet. Comprobar bloqueo, equipamiento inmediato, muerte, cierre/reapertura y error de guardado.
3. Capturar y comparar píxeles del original y cada recompensa en el juego real; no aceptar solo parámetros diferentes de shader. Revisar también el personaje pequeño y las poses extremas.
4. Para franquicias ajenas, distinguir inspiración, cameo oficial y material licenciado; explicar los límites de uso para publicación sin afirmar que existe licencia. Validar y guardar el skill y los cambios del proyecto por sus flujos autorizados. Verificar CI y el APK si forman parte del encargo. Comunicar resultados y límites observados sin afirmar pruebas físicas que no se realizaron.
