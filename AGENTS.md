# Trabajo en Juego Diego

Leer `docs/ARQUITECTURA.md` antes de cambiar la estructura o añadir sistemas.

Para diseñar, generar, editar o preparar personajes de Super Diego (antes Salto Heroes), utilizar el skill del repositorio:

- Nombre: `generar-personajes-salto-heroes`.
- Entrada: `.agents/skills/generar-personajes-salto-heroes/SKILL.md`.
- Cargar sus referencias según el tipo de encargo.

Para diseñar o revisar dinámicas jugables, llaves, recorridos y progresión de niveles, utilizar:

- Nombre: `crear-dinamicas-salto-heroes`.
- Entrada: `.agents/skills/crear-dinamicas-salto-heroes/SKILL.md`.
- Leer `docs/DINAMICAS.md` y contrastar su inventario con el código actual.
- Planificar tres aventuras antes del jefe de cada mundo. Conservar Bosque 1-1 en 9,2–10,94 minutos estimados por la reducción del 17-10-2026; para futuras aventuras mantener al menos 15 minutos, inicialmente 18–22 estimados, salvo instrucción posterior. Medir jugando.
- Mantener tres llaves distintas por aventura y al menos una zona secreta opcional en cada aventura nueva. Antes de implementarla, presentar y validar con el usuario dónde estará y qué se hará; señalar su acceso mediante un tótem coherente con el mundo.
- Repartir los coleccionables especiales por dificultad: accesibles en nivel 1, intermedios en nivel 2 y máximos en nivel 3 (última aventura, antes del jefe). Mantener dificultad apropiada para 10 años y no exigir colección completa ni todas las hojas para avanzar o desbloquear ropa.
- Usar exactamente tres puntos de guardado por nivel. Activarlos conserva vidas actuales y máximo, sin curación; repartirlos sobre suelo seguro sin añadir faroles por intervalo de tiempo.
- Conservar doble salto, lianas oscilantes, avance agachado, recuperación espacial por farol y colección permanente. Usar fichas versión 2 y el comprobador con `--actual` para diseños nuevos; separar propuestas, implementación y pruebas.
- Crear o mantener este skill no autoriza por sí solo añadir niveles, mecánicas ni arte al juego.

Mantener los requisitos confirmados de 2D, Android y Windows, ocho mundos, niveles rejugables, enemigos eliminables por pisotón y jefes atacados mediante objetos lanzados. No inventar el contenido de la elección artística «opción A» si su especificación no está disponible.

Una petición de mantener skills, documentación o arquitectura no pide generar arte ni añadir contenido jugable. La escena vacía solo se ampliará cuando el usuario pida desarrollar o integrar contenido.

Para diseñar o integrar recompensas, ropa, accesorios y su presentación, utilizar:

- Nombre: `crear-recompensas-super-diego`.
- Entrada: `.agents/skills/crear-recompensas-super-diego/SKILL.md`.
- Conservar IDs y guardados, verificar apariencia en el jugador real y mantener salida fija del vestuario.
