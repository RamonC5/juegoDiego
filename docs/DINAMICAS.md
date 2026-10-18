# Dinámicas y progresión de Super Diego

Diseño para un niño de 10 años: ocho mundos, cada uno con tres aventuras y un jefe posterior. Los niveles superados siguen disponibles. Cada aventura requiere tres llaves de su ambiente, recogidas automáticamente y sin ocupar las manos; hojas, cristales y secretos permanecen opcionales.

## Autoría de niveles: decisiones del 18-10-2026

Aplicar el skill actualizado al diseñar niveles nuevos: incluir al menos una zona secreta opcional por aventura y, **antes de implementarla**, proponer y validar con el usuario su ubicación y lo que Diego hace dentro. Registrar la respuesta real; si cambia la ubicación o actividad, volver a consultar. Señalar siempre la entrada con un tótem del estilo del mundo, sin letras ni iconos flotantes; ofrecer entrada, premio y retorno físicos sin impedir las tres llaves.

Repartir los objetos especiales de colección por dificultad: iniciales y accesibles desde la aventura 1; intermedios (el escalón inmediatamente anterior al máximo) en la aventura 2; máximos en la aventura 3, última antes del jefe. Mantener hojas comunes en todas y retos alcanzables para 10 años. Esta regla de diseño no recoloca objetos existentes ni cambia automáticamente los trajes por hojas. No exigir todas las hojas ni colección completa para avanzar o desbloquear ropa.

Usar fichas versión 2 y el comprobador con `--actual`; con `--mundo`, adjuntar las tres aventuras y su jefe. Conservar fichas históricas en versión 1 sin inventar aprobaciones. Ver [decisiones del skill](../.agents/skills/crear-dinamicas-salto-heroes/references/secretos-y-coleccion.md).

## Colección y recompensas · 0.8.0

Regla vigente 0.11.1: las hojas acumuladas desbloquean pañuelo (12), chaleco (45), explorador (60), guardián (80), Ladybug (100) y Ladybug estelar (150), sin gastarse. Ningún traje exige colección completa, secretos, cristales ni fragmentos; sustituye los requisitos históricos de 0.8.0. Tres fragmentos opcionales, en el claro inicial, la gruta y las lianas, despiertan al acompañante Luci. La ropa es cosmética y estas recompensas no condicionan las tres llaves ni la salida.

El guardado inmediato conserva colección y equipo al morir, cerrar y rejugar, evitando duplicados por ID. Es independiente del reinicio espacial de los mecanismos y de los resultados. El vestuario pausa el juego; Luci se puede desactivar y no añade gestos. La duración principal mantiene la excepción anterior y no se atribuye tiempo medido a los coleccionables.

[Ficha de dinámica](dinamicas/coleccion_bosque.json) · [Reglas](RECOMPENSAS.md) · [Evidencia](pruebas/coleccion-0.8.0.md).

## Corrección anterior sobre plataformas reales · 0.7.5

Soltar abajo o deslizar arriba permite ponerse de pie debajo de las plataformas que se atraviesan al saltar. Solo un techo sólido mantiene la cápsula baja; sigue siendo posible salir avanzando o retrocediendo. El farol guarda las aperturas anteriores y restaura expresamente sus dianas, portones y colisiones, mientras rearma los puzzles posteriores. [Pruebas de retorno](pruebas/recuperacion-0.7.5.md).

## Recuperación y pasos bajos · 0.7.4

Diego puede avanzar y retroceder agachado bajo un bloque, con el mismo dedo que desliza abajo o con un contacto adicional. Si suelta abajo sin espacio para levantarse, otro arrastre le permite salir y recupera la postura al quedar libre.

Morir conserva lo resuelto antes del farol y restablece únicamente el tramo posterior: puentes, portones, sus dianas y piñas, enemigos y ciclos móviles. La posición de origen decide la recuperación, incluso al volver atrás. Las llaves y coleccionables del intento se conservan. Esta regla sustituye los reinicios globales y temporales descritos en las versiones históricas inferiores. [Contrato y pruebas](ARQUITECTURA.md#recuperación-por-farol-y-salida-agachado--074).

## Gruta secreta de hojas · 0.7.2

Junto al tótem de madera y musgo, alrededor de x=11610, agacharse abre la trampilla. El túnel permite caminar realmente por debajo del bosque: sigue las hojas hacia la izquierda, recoge el brote de vida y sal por el ascensor de x=10340. La galería mide 1890 px; el ascensor está separado de la entrada. Su cuarto corazón se concede una sola vez por intento y se conserva al reaparecer. El desvío es opcional y mantiene accesibles las tres llaves y los portones.

El tótem y las lianas tienen acabado raster coherente con el escenario. Las lianas conservan la velocidad del balanceo al saltar y el agarre se aproxima suavemente al nudo. El recorrido continuo de pruebas supera el barranco sin trasladar a Diego entre las cuerdas.

[Especificación del secreto](dinamicas/gruta_hojas_vida.json) · [Barranco de lianas](dinamicas/lianas_dianas_barranco.json) · [Datos del bosque](niveles/world_01_level_01.json).

## Estado y alcance

**Actualización 0.7.0 (prioritaria):** el bosque ahora consta de un prólogo y nueve tramos, 45 enemigos y tres llaves. La duración objetivo es **9,2–10,94 minutos estimados**, aproximadamente la mitad de la versión larga, por petición expresa del 17-10-2026. Se incorpora el [barranco de lianas y dianas](dinamicas/lianas_dianas_barranco.json): cinco lianas oscilantes que se enlazan saltando, con agarre automático aéreo y recuperación desde la orilla. Véase el [recorrido actualizado](niveles/world_01_level_01.json). Los valores de 19 tramos y 18–22 minutos descritos a continuación son **históricos (0.5.0)**, no el nivel que se exporta actualmente.

El bosque histórico 0.5.0 contenía 19 tramos, 81 enemigos con persecución (38 guardianes de plataforma), tres llaves repartidas en tres rutas, 19 pasos de dos marcas, ocho puentes, ocho troncos y 21 faroles. El guardado conserva resultados completados; cerrar reinicia el intento. La ampliación está integrada y la duración de 18–22 minutos sigue siendo estimada, sin medición del público objetivo.

[Recorrido actual](niveles/world_01_level_01.json) · [Raíces dobles](dinamicas/raices_dobles.json) · [Persecución](dinamicas/persecucion_bosque.json) · [Contenido y evidencia](BOSQUE_ESMERALDA.md). Las fichas antiguas del puente y los troncos conservan su contexto de integración inicial. Los otros niveles y jefes siguen pendientes. El inventario del skill está contrastado documentalmente hasta 0.11.1; revisarlo contra el código al integrar.

## Duración y recuperación

Para el **primer bosque** prevalece la reducción específica autorizada a unos 9–11 minutos. El objetivo general de 15 minutos para futuras aventuras sigue vigente si el usuario no decide lo contrario. Las medidas están pendientes de partidas reales.

Dimensionar cada aventura para al menos 15 minutos de ruta principal en primera partida normal. Usar inicialmente un presupuesto de 18–22 minutos y comprobarlo jugando; descontar pausas, cargas, cinemáticas, secretos y repeticiones por derrota. Las rejugadas expertas pueden ser más cortas. No imponer un tiempo de espera para abrir la puerta.

Introducir una o dos dinámicas obligatorias nuevas por nivel y alternar plataformas, exploración, combate y pequeños rompecabezas. Enseñar primero en un lugar seguro, practicar y combinar después. Situar faroles aproximadamente cada 3–4 minutos. Al reaparecer conservar el tramo anterior al farol y repetir el posterior; una diana pertenece al puente o portón que acciona aunque esté situada antes. Reponer herramientas imprescindibles y permitir regresar a una llave pendiente. Proponer guardado del intento como sistema nuevo para poder continuar otro día.

## Progresión propuesta del primer mundo

Los nombres y la distribución nueva son propuestas de diseño, no niveles ya implementados.

| Etapa | Dinámicas nuevas previstas | Progresión |
| --- | --- | --- |
| 1-1 · El despertar del bosque ampliado | Puente de diana y troncos viajeros | Integrado: prólogo y nueve tramos, lianas, gruta con tótem y tres llaves. 9,2–10,94 minutos estimados, pendientes de medir. |
| 1-2 · Las copas inquietas | Setas de rebote propuestas; combinar plataformas móviles y objetos intermedios | Explorar alturas. Introducir Nóctilo cuando tenga comportamiento jugable, primero de forma opcional si añade una tercera dinámica nueva. |
| 1-3 · El corazón de las raíces | Placas de peso propuestas; combinar avance agachado conocido y objetos máximos | Resolver pasos estrechos y mecanismos; practicar lanzamientos antes del jefe. |
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





## Ajuste 0.5.2 · Persecución desde plataformas y presentación

La petición posterior permite a todos los enemigos perseguir y bajar de estructuras. Sustituye la restricción anterior de los guardianes de plataforma durante la persecución; la patrulla tranquila sigue respetando los bordes. El HUD usa iconos con cantidades, el salto tiene un impulso de 680 px/s y la cámara acompaña la caída sin limitarse a 260 px/s. El componente `game/ui/hud/hud_counter.gd` reúne presentación y descripciones accesibles; las reglas de combate y recogida siguen en sus funcionalidades. [Detalles y pruebas](PULIDO_0.5.2.md).



## Recuperación y presentación · 0.6.0

Las derrotas posteriores al farol se repiten al morir, incluidas las de enemigos encontrados al volver atrás. Activar el siguiente farol consolida las anteriores. Las llaves y mecanismos siguen conservándose. La música de bosque es ambiental y ajustable; ninguna condición jugable depende de escucharla. Dianas, pasos, troncos y faroles usan símbolos sin letras, con instrucciones en pausa. [Implementación](ARQUITECTURA.md#música-por-nivel-reaparición-y-señales-visuales--060).


## Dianas destructibles y escenario despejado · 0.6.1

Un lanzamiento válido rompe la diana en fragmentos; morir reconstruye todas las dianas, incluidas las anteriores al farol. Los mecanismos y las llaves ya resueltos se conservan, y romper una diana reparada no duplica el progreso. Esta regla sustituye la diana activada permanente. Se retiran los iconos flotantes de escenario; las instrucciones permanecen en pausa. El nuevo tema de plataformas **Esmeralda en marcha** usa batería, bajo y sintetizadores a 128 BPM. [Contrato actual](ARQUITECTURA.md#rotura-y-reconstrucción-de-dianas--061).


## Revisión del barranco · Lianas oscilantes (17-10-2026)

Se sustituye la liana fija que hacía ascender automáticamente y los cinco discos de rebote: ahora hay **cinco lianas oscilantes**, con fases independientes. Diego **salta** para agarrarse automáticamente al nudo visible, se **balancea** y pulsa de nuevo **salto** para soltarse y alcanzar la siguiente liana. Arrastrar horizontalmente ayuda a orientar el movimiento; se mantienen controles táctiles sin botones y equivalencia con teclado/mando. La caída vuelve a dejar el agarre libre y permite reintentar desde la orilla inicial. [Ficha actualizada](dinamicas/lianas_dianas_barranco.json).


## Controles y reserva aérea · 0.7.3

Una pulsación en la mitad izquierda inicia un salto completo y otra en el aire añade un único segundo impulso. El arrastre pasa a la derecha junto con agacharse y recoger/lanzar; las mitades siguen siendo intercambiables. Al soltarse de una liana queda un salto aéreo, y el siguiente agarre renueva la reserva. La pose de manos elevadas gira alrededor del contacto con la cuerda; las colisiones y las reglas de recuperación se conservan. [Controles y pruebas](CONTROLES_TACTILES.md).
