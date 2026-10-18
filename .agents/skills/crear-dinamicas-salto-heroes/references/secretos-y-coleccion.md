# Secretos y colección: decisiones vigentes

Aplicar las instrucciones actuales del usuario y contrastar `docs/RECOMPENSAS.md` y el catálogo real. Acuerdos consolidados el 18-10-2026; esta referencia define autoría futura, no certifica niveles añadidos.

## Consulta previa del secreto

Preparar una propuesta breve y concreta antes de preguntar: «Para [mundo/nivel], propongo la entrada [ubicación respecto a un hito], señalada por [tótem del ambiente]. Dentro, Diego [actividad], consigue [premio] y vuelve por [salida]. ¿Validas esta ubicación y lo que se hace dentro, o quieres cambiar algo?».

Guardar ubicación y actividad junto con la decisión real del usuario y su fecha. Una orden genérica de crear un nivel no valida una propuesta que aún no se ha presentado. No implementar la zona pendiente; sí preparar su ficha y avanzar con trabajo independiente. Reutilizar la aprobación de esa propuesta sin repetir la consulta; si cambia dónde está o qué se hace, consultar la modificación. No inventar una respuesta para completar el JSON.

Señalar cada acceso con un tótem visible que use los materiales y el acabado del mundo. En bosque, madera, raíces, musgo y hojas; no trasladar estos materiales a todos los ambientes por defecto. Conservar el estilo raster 2D HD, iluminación y escala del escenario, sin carteles, letras o iconos flotantes. Usar silueta, animación suave de proximidad y pistas accesibles en pausa; no depender solo del color, sonido o de tener a Luci.

Incluir por aventura nueva al menos un secreto opcional con entrada física, actividad comprensible, premio y retorno seguro. Permitir completar las tres llaves sin visitarlo. Revisar cámara, suelo bajo tierra, techo, bordes del ascensor, reentrada, muerte, pausa y salida. No hacer desaparecer el acceso al conseguir el premio ni duplicar el premio al reentrar.

Tomar la gruta del primer bosque como precedente: trampilla junto al tótem, acceso agachándose, paseo bajo el bosque siguiendo hojas, brote de vida y ascensor de retorno separado. Una vida adicional se concede una vez por intento y se conserva al reaparecer; hojas, cristales y fragmentos conservan su propia persistencia permanente. No copiar sus coordenadas ni atribuir aprobación a un secreto nuevo por parecido.

## Distribución por dificultad relativa

| Aventura del mundo | Colección especial | Diseño |
| --- | --- | --- |
| 1 | Objetos iniciales y accesibles | Enseñar acciones y reconocer la colección; ofrecer hojas comunes. |
| 2 | Escalón intermedio, el inmediatamente anterior al más difícil | Combinar acciones practicadas con recuperación cercana; mantener hojas comunes. |
| 3, última aventura | Objetos del escalón máximo | Ofrecer el reto opcional más exigente del mundo con señales y reintentos adecuados a 10 años; mantener hojas comunes. |
| Jefe posterior | Encuentro separado | No trasladar aquí los objetos reservados a la tercera aventura. |

Poder añadir objetos iniciales en las aventuras segunda y tercera. Reservar intermedios a la segunda y máximos a la tercera; no generar antes versiones duplicadas de esos mismos objetos. Comparar la dificultad entre objetos del mismo mundo, sin convertir «máxima» en precisión extrema. Definir en cada ficha ID, dificultad, segmento, acción y persistencia; indicar qué premio alimenta, o que solo completa la colección. Comprobar el conjunto del mundo con `--mundo --actual`.

Separar colección permanente, tres llaves de cada intento y herramientas para puzzles/combate. Reponer las herramientas necesarias; no consumir un objeto único de colección para abrir el paso obligatorio. No exigir todos los objetos, hojas, cristales o secretos para la salida ni para ropa. Mantener progreso entre intentos sin duplicados y conservar IDs/equipo al actualizar.

## Recompensas confirmadas y compatibilidad

Mantener ropa cosmética por hojas acumuladas, sin gastar: pañuelo 12, chaleco 45, explorador 60, guardián 80, Ladybug 100 y Ladybug estelar 150. No restaurar la exigencia antigua de todas las hojas ni colección completa; tampoco fragmentos o cristales para trajes. Luci se desbloquea con tres fragmentos opcionales. Mantener identidad de Diego y el estilo del juego, premios visibles en todas las poses y Volver/Seguir jugando fijos en vestuario.

La distribución futura de objetos por niveles no cambia automáticamente estos umbrales ni bloquea los premios ya ganados. Cualquier recolocación requiere un encargo de integración y revisión de IDs, manifiesto y guardados: hojas/cristales actuales usan coordenadas en su identidad; moverlos sin compatibilidad puede duplicar o perder progreso.
