# Dinámicas y progresión de Salto Heroes

Diseño para un niño de 10 años: ocho mundos, cada uno con tres aventuras y un jefe posterior. Los niveles superados siguen disponibles. Cada aventura requiere tres llaves de su ambiente, recogidas automáticamente y sin ocupar las manos; hojas, cristales y secretos permanecen opcionales.

## Estado y alcance

El bosque experimental contiene movimiento, salto, agacharse sin avanzar, pisotones, lanzamientos, Terrón y Moflete, tres llaves de ramas, puerta y un farol. El guardado actual conserva resultados completados; no guarda un intento al cerrar a mitad de nivel. No hay una medición de 15 minutos en el perfil objetivo.

La ampliación, los otros niveles y los jefes son trabajo pendiente. La entrega del skill añade documentación y herramientas de autoría, sin cambiar escenas, datos jugables ni controles. El [inventario del prototipo](../.agents/skills/crear-dinamicas-salto-heroes/references/estado-prototipo.md) registra fuentes y commit; contrastarlo al usarlo.

## Duración y recuperación

Dimensionar cada aventura para al menos 15 minutos de ruta principal en primera partida normal. Usar inicialmente un presupuesto de 18–22 minutos y comprobarlo jugando; descontar pausas, cargas, cinemáticas, secretos y repeticiones por derrota. Las rejugadas expertas pueden ser más cortas. No imponer un tiempo de espera para abrir la puerta.

Introducir una o dos dinámicas obligatorias nuevas por nivel y alternar plataformas, exploración, combate y pequeños rompecabezas. Enseñar primero en un lugar seguro, practicar y combinar después. Situar faroles aproximadamente cada 3–4 minutos. Conservar objetivos resueltos al reaparecer, reponer herramientas imprescindibles y permitir regresar a una llave pendiente. Proponer guardado del intento como sistema nuevo para poder continuar otro día.

## Progresión propuesta del primer mundo

Los nombres y la distribución nueva son propuestas de diseño, no niveles ya implementados.

| Etapa | Dinámicas nuevas previstas | Progresión |
| --- | --- | --- |
| 1-1 · El despertar del bosque ampliado | Puente activado por una diana y un lanzamiento | Repartir las llaves entre plataformas, mecanismo del puente y un recorrido combinado. |
| 1-2 · Las copas inquietas | Plataformas móviles y setas de rebote | Explorar alturas. Introducir Nóctilo cuando tenga comportamiento jugable, primero de forma opcional si añade una tercera dinámica nueva. |
| 1-3 · El corazón de las raíces | Avanzar agachado y placas de peso | Resolver pasos estrechos y mecanismos; practicar lanzamientos antes del jefe. |
| Jefe del bosque | Patrones y vulnerabilidad a objetos lanzados | Desbloquear tras completar las tres aventuras; ofrecer objetos de reposición y repetición del combate. |

No fijar los nombres ni las temáticas de los otros siete mundos a partir del catálogo de llaves. El mínimo de 15 minutos se refiere a las aventuras; el encuentro separado con el jefe tendrá un ritmo propio.

## Skill y fichas

Usar [`crear-dinamicas-salto-heroes`](../.agents/skills/crear-dinamicas-salto-heroes/SKILL.md), invocándolo como `$crear-dinamicas-salto-heroes`. Incluye reglas, catálogo, inventario verificado, plantillas JSON y ejemplos de un puente y una ampliación del bosque.

Guardar las fichas en `docs/dinamicas/<id>.json` y los recorridos en `docs/niveles/<id>.json`, y enlazarlos aquí. Registrar objetivo, controles, aprendizaje, dependencias, éxito, fallo, recuperación, persistencia, accesibilidad, tiempos y pruebas. Diferenciar siempre propuesta, implementación y evidencia.

### Primera dinámica del nivel 1 · El puente de raíces

[Diseño del puente de raíces](dinamicas/puente_diana.md) · [Ficha JSON verificable](dinamicas/puente_diana.json).

Aplicación de `crear-dinamicas-salto-heroes` a `world_01_level_01`: aprender a lanzar una piña a una diana en una pasarela segura y aplicar después la misma relación para abrir el puente principal y alcanzar la segunda llave de ramas. Se reutilizan gestos, lanzamientos y pisotón; las dos estaciones enseñan una sola dinámica nueva.

Estado: **propuesta**, contrastada con `main` en el commit `dd5d7891fa421a6c23befe1479421ed38e942f2d`. El diseño detalla reposición local de piñas, retorno, faroles, apertura conservada al morir, accesibilidad y pruebas pendientes. Requiere integrar dianas conectadas a puentes, generalizar faroles y ajustar datos del recorrido. La piña existe, pero el bosque actual no incluye su índice 2 en los puestos; se registra la discrepancia con la pista que menciona una piña donde hay una vasija.

El bloque completo presupuesta **4–5 minutos estimados**, incluidos una sola vez en el futuro recorrido de 18–22 minutos. No acredita el mínimo de 15 minutos de la aventura completa ni incorpora guardado de intentos al cerrar la aplicación.

Validar la ficha desde la raíz del proyecto:

```sh
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py docs/dinamicas/puente_diana.json
```

### Ejemplos del skill

Los [ejemplos de autoría](../.agents/skills/crear-dinamicas-salto-heroes/assets/) están marcados como propuestas. El del bosque presupuesta 18–21,6 minutos principales y excluye sus desvíos opcionales; ese cálculo no acredita duración real.

Comprobar los ejemplos desde la raíz:

```sh
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py .agents/skills/crear-dinamicas-salto-heroes/assets/ejemplo-dinamica-puente.json .agents/skills/crear-dinamicas-salto-heroes/assets/ejemplo-nivel-bosque.json
```

El comprobador usa únicamente Python 3, no modifica archivos y revisa consistencia documental. Para validar un mundo completo, pasar las tres fichas de aventura y la del jefe con `--mundo`. Faltan siempre las comprobaciones físicas, de duración, tacto y rendimiento que aún no se hayan realizado.

