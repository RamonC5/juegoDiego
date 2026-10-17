# Dinámicas y progresión de Salto Heroes

Diseño para un niño de 10 años: ocho mundos, cada uno con tres aventuras y un jefe posterior. Los niveles superados siguen disponibles. Cada aventura requiere tres llaves de su ambiente, recogidas automáticamente y sin ocupar las manos; hojas, cristales y secretos permanecen opcionales.

## Estado y alcance

El bosque 0.5.0 contiene 19 tramos, 81 enemigos con persecución (38 guardianes de plataforma), tres llaves repartidas en tres rutas, 19 pasos de dos marcas, ocho puentes, ocho troncos y 21 faroles. El guardado conserva resultados completados; cerrar reinicia el intento. La ampliación está integrada y la duración de 18–22 minutos sigue siendo estimada, sin medición del público objetivo.

[Recorrido actual](niveles/world_01_level_01.json) · [Raíces dobles](dinamicas/raices_dobles.json) · [Persecución](dinamicas/persecucion_bosque.json) · [Contenido y evidencia](BOSQUE_ESMERALDA.md). Las fichas antiguas del puente y los troncos conservan su contexto de integración inicial. Los otros niveles y jefes siguen pendientes. El inventario del skill es una instantánea anterior; contrastarlo con el código actual.

## Duración y recuperación

Dimensionar cada aventura para al menos 15 minutos de ruta principal en primera partida normal. Usar inicialmente un presupuesto de 18–22 minutos y comprobarlo jugando; descontar pausas, cargas, cinemáticas, secretos y repeticiones por derrota. Las rejugadas expertas pueden ser más cortas. No imponer un tiempo de espera para abrir la puerta.

Introducir una o dos dinámicas obligatorias nuevas por nivel y alternar plataformas, exploración, combate y pequeños rompecabezas. Enseñar primero en un lugar seguro, practicar y combinar después. Situar faroles aproximadamente cada 3–4 minutos. Conservar objetivos resueltos al reaparecer, reponer herramientas imprescindibles y permitir regresar a una llave pendiente. Proponer guardado del intento como sistema nuevo para poder continuar otro día.

## Progresión propuesta del primer mundo

Los nombres y la distribución nueva son propuestas de diseño, no niveles ya implementados.

| Etapa | Dinámicas nuevas previstas | Progresión |
| --- | --- | --- |
| 1-1 · El despertar del bosque ampliado | Puente de diana y troncos viajeros | Integrado: prólogo y tres rutas de seis retos con llaves separadas, dos marcas y persecución. Duración pendiente de medir. |
| 1-2 · Las copas inquietas | Setas de rebote; combinar con plataformas móviles ya conocidas | Explorar alturas. Introducir Nóctilo cuando tenga comportamiento jugable, primero de forma opcional si añade una tercera dinámica nueva. |
| 1-3 · El corazón de las raíces | Avanzar agachado y placas de peso | Resolver pasos estrechos y mecanismos; practicar lanzamientos antes del jefe. |
| Jefe del bosque | Patrones y vulnerabilidad a objetos lanzados | Desbloquear tras completar las tres aventuras; ofrecer objetos de reposición y repetición del combate. |

No fijar los nombres ni las temáticas de los otros siete mundos a partir del catálogo de llaves. El mínimo de 15 minutos se refiere a las aventuras; el encuentro separado con el jefe tendrá un ritmo propio.

## Skill y fichas

Usar [`crear-dinamicas-salto-heroes`](../.agents/skills/crear-dinamicas-salto-heroes/SKILL.md), invocándolo como `$crear-dinamicas-salto-heroes`. Incluye reglas, catálogo, inventario verificado, plantillas JSON y ejemplos de un puente y una ampliación del bosque.

Guardar las fichas en `docs/dinamicas/<id>.json` y los recorridos en `docs/niveles/<id>.json`, y enlazarlos aquí. Registrar objetivo, controles, aprendizaje, dependencias, éxito, fallo, recuperación, persistencia, accesibilidad, tiempos y pruebas. Diferenciar siempre propuesta, implementación y evidencia.

### Primera dinámica del nivel 1 · El puente de raíces

[Diseño del puente de raíces](dinamicas/puente_diana.md) · [Ficha JSON verificable](dinamicas/puente_diana.json).

Aplicación de `crear-dinamicas-salto-heroes` a `world_01_level_01`: aprender a lanzar una piña a una diana en una pasarela segura y aplicar después la misma relación para abrir el puente principal y alcanzar la segunda llave de ramas. Se reutilizan gestos, lanzamientos y pisotón; las dos estaciones enseñan una sola dinámica nueva.

Estado: **implementada en 0.3.0**, sobre `main` en el commit `11b12f2bd35ad1c068c41be50d5d85082a16ccef`. Incluye piñas con recuperación local, dos puentes, suelo y escalones de ensayo, segunda llave reubicada, tres faroles y aperturas conservadas al morir. La pista del puesto de vasija se ha corregido. Las cuatro suites suman 264 comprobaciones correctas, incluidas 55 de puentes y un recorrido completo con entradas reales.

Los **4–5 minutos** fueron el presupuesto inicial de autoría; no están medidos con un niño ni acreditan 15 minutos del nivel actual. Ampliar la aventura hasta ese mínimo y medir primeras partidas sigue pendiente. El cierre de la aplicación continúa reiniciando el intento.

Validar la ficha desde la raíz del proyecto:

```sh
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py docs/dinamicas/puente_diana.json
```

### Segunda dinámica del nivel 1 · Troncos viajeros

[Diseño y recuperación](dinamicas/troncos_viajeros.md) · [Ficha JSON](dinamicas/troncos_viajeros.json).

La versión 0.4.0 añade una plataforma horizontal de ensayo y un tronco ascendente que da acceso a la tercera llave, reubicada en una repisa alta. Usa movimiento y salto existentes, viaje sin mantener arrastre, suelo seguro y ciclos que vuelven a sus puestos. La primera dinámica del puente permanece integrada. Los 2–4 minutos iniciales son una estimación de autoría; la CI supera 292 comprobaciones, incluidas 27 de troncos. La duración observada sigue pendiente.

### Refuerzo de combate del nivel 1 · 0.4.1

Se añaden dos encuentros de la dinámica conocida `pisoton_patrullas`: Terrón después de la primera llave y Moflete en el tramo final. El bosque pasa a nueve patrullas, con las tres llaves como única condición de la puerta. [Posiciones, recuperación y tiempo informado por el usuario](BOSQUE_ESMERALDA.md). No se introduce una tercera dinámica obligatoria ni se atribuyen 15 minutos a este ajuste.

### Ejemplos del skill

Los [ejemplos de autoría](../.agents/skills/crear-dinamicas-salto-heroes/assets/) están marcados como propuestas. El del bosque presupuesta 18–21,6 minutos principales y excluye sus desvíos opcionales; ese cálculo no acredita duración real.

Comprobar los ejemplos desde la raíz:

```sh
python3 .agents/skills/crear-dinamicas-salto-heroes/scripts/validar_dinamicas.py .agents/skills/crear-dinamicas-salto-heroes/assets/ejemplo-dinamica-puente.json .agents/skills/crear-dinamicas-salto-heroes/assets/ejemplo-nivel-bosque.json
```

El comprobador usa únicamente Python 3, no modifica archivos y revisa consistencia documental. Para validar un mundo completo, pasar las tres fichas de aventura y la del jefe con `--mundo`. Faltan siempre las comprobaciones físicas, de duración, tacto y rendimiento que aún no se hayan realizado.


