# Bosque Esmeralda · 1-1 · 0.5.0

El bosque se amplía a tres rutas de llaves, tras un prólogo que enseña salto, lanzamiento, puentes y troncos viajeros. Sigue siendo el primer nivel de Super Diego y se abre al iniciar; Entrenamiento permanece en Pausa.

## Contenido actual

| Elemento | Integración |
| --- | --- |
| Recorrido | 80 600 px lógicos, 19 tramos con nombre: prólogo y tres rutas de seis combinaciones |
| Llaves | Exactamente tres, tras los pasos de x=32 090, 56 090 y 80 090; recogida automática y manos libres |
| Enemigos | 41 Terrones y 40 Mofletes; 38 de los 81 defienden plataformas |
| Raíces | 19 pasos con dos dianas numeradas; ambas abren el paso de forma permanente |
| Puentes | Ocho estaciones de lanzamiento con piña propia y reposición |
| Troncos | Ocho plataformas móviles: ensayo horizontal y ascensores combinados con estaciones altas |
| Recuperación | 21 faroles, energía completa al activar uno nuevo, suelos inferiores y peldaños de regreso |
| Opcionales | Hojas y tres cristales; nunca abren la puerta ni se cuentan en el presupuesto principal |
| Salida | x=80 400; requiere las tres llaves y no consulta un temporizador |

Las rutas posteriores cambian el orden, aumentan los ascensos de las segundas marcas y añaden troncos diagonales. Las composiciones alternan terrazas de helecho, barrancos, copas viajeras, escaleras de guardianes y cruces de dos orillas. Las repisas se suben en peldaños de 85 px; las copas altas requieren viajar y saltar desde el tronco. La dificultad combina acciones conocidas. No se alarga el nivel con esperas impuestas.

[Recorrido de autoría](niveles/world_01_level_01.json) · [Raíces dobles](dinamicas/raices_dobles.json) · [Persecución](dinamicas/persecucion_bosque.json).

## Comportamiento de los enemigos

Ambas especies detectan a Diego por distancia, altura y línea de visión libre. Muestran **!**, esperan 0,42 s para dar tiempo a reaccionar y avanzan hacia él. Terrón persigue a 112 px/s y Moflete a 142 px/s, por debajo de los 210 px/s de Diego andando. Cuando pierden la vista regresan a su origen; paredes, distancia al origen y sondeos del suelo limitan el seguimiento.

Los del suelo salen de su patrulla corta para atacar. Los guardianes persiguen dentro de la plataforma que los sostiene y frenan en sus bordes: nunca saltan tras Diego. Se mantienen los pisotones, lanzamientos y daño lateral existentes. No es obligatorio derrotarlos todos.

## Recuperación y retorno

Las piñas perdidas regresan a los cuatro segundos. Pausar detiene ciclos, enemigos y reposición. Morir conserva llaves y coleccionables, pero desde 0.6.3 repliega todos los puentes, bloquea las barreras y repara las dianas; hay que resolverlas otra vez. Vuelve al farol, repone energía y herramientas y limpia la alerta de enemigos vivos. Un farol anterior no hace retroceder la reaparición.

Todos los pasos abiertos permiten volver atrás y buscar objetivos pendientes. Se usan más faroles que la pauta general de 3–4 minutos porque anteceden a nuevas combinaciones y ofrecen recuperación de energía para el público objetivo. Rejugar repone el nivel, conservando mejores resultados. Cerrar la aplicación todavía reinicia el intento: no hay guardado intermedio.

## Duración y evidencia

El usuario informó aproximadamente **45 segundos** en la versión anterior. La ampliación tiene un presupuesto exclusivo de **18,2–21,8 minutos** para primera partida normal; es una **estimación de autoría**, pendiente de medir con el público objetivo. No se suman secretos, cargas, pausas ni reintentos. No se exige esperar para salir; una rejugada experta puede ser bastante menor.

La ruta automatizada continua aísla geometría y mecanismos desactivando la colisión enemiga, y usa movimiento, saltos, transporte y lanzamientos físicos. Recorre las 38 marcas, ocho puentes, tres llaves y puerta sin teletransportar a Diego durante el recorrido. Su tiempo simulado no es una primera partida del público objetivo. La percepción, persecución, bordes, daño y pisotones se comprueban en suites separadas.

Las regresiones antiguas de bosque, puentes y troncos usan `tools/tests/fixtures/forest_mechanics.tres`: conservan los ensayos originales y sus coordenadas para aislar esos contratos. Las pruebas de ampliación y ruta cargan el nivel real. La CI también lee el recurso binario extraído del APK para comprobar posiciones, tipos, raíces y llaves, e instala el APK ARM64 en Android API 35. Las capturas requieren revisión visual.

El objetivo es 60 FPS; la prueba automatizada no acredita rendimiento ni tacto en un teléfono físico. Siguen pendientes la medición de primeras partidas de un niño de 10 años y las pruebas físicas Android y Windows.

## Controles y arte

Arrastrar para moverse; deslizar arriba en la otra mitad para saltar; toque para coger y lanzar. Pausa conserva sensibilidad, mitades intercambiadas, carrera opcional, salto completo y reasignación. Teclado A/D o flechas, Espacio, E y Escape; mando existente.

Se reutiliza el arte raster HD, Terrón, Moflete y las raíces actuales. Las nuevas raíces verticales usan recortes y transformaciones, sin modificar los PNG. La colisión procede de los datos del nivel. Se mantienen los ocho identificadores de mundo; esta entrega solo amplía `world_01_level_01`.

La corrección de los enemigos ausentes en APK 0.4.2 se conserva: `enemy_kinds` es `Array[String]`, con preloads explícitos y verificación del recurso exportado. [Diagnóstico anterior](pruebas/apk-enemigos-0.4.2.md).

## Entrega validada

[CI de 0.5.0-ci.41](https://github.com/RamonC5/juegoDiego/actions/runs/39017850472), sobre `a160e9825cee34727a03480099d72067c34bd83d`: **474 comprobaciones correctas**, exportación y firma verificadas e instalación Android API 35 terminada correctamente. Revisadas las capturas finales de escritorio, Terrón visible en Android y Pausa mostrando la versión correcta. [Auditoría, checksum y límites](pruebas/bosque-0.5.0.json). La duración de 18–22 minutos conserva el estado estimado.



## Ajuste 0.5.2 · Persecución desde plataformas y presentación

La petición posterior permite a todos los enemigos perseguir y bajar de estructuras. Sustituye la restricción anterior de los guardianes de plataforma durante la persecución; la patrulla tranquila sigue respetando los bordes. El HUD usa iconos con cantidades, el salto tiene un impulso de 680 px/s y la cámara acompaña la caída sin limitarse a 260 px/s. El componente `game/ui/hud/hud_counter.gd` reúne presentación y descripciones accesibles; las reglas de combate y recogida siguen en sus funcionalidades. [Detalles y pruebas](PULIDO_0.5.2.md).



## Ajuste 0.6.0

El nivel incorpora **Senderos de Esmeralda**, música instrumental original del bosque en bucle, con volumen y silencio desde pausa. Morir restaura las patrullas derrotadas después del último farol; antes del primero se restauran desde el inicio. Las derrotas previas al farol, llaves y coleccionables se conservan; desde 0.6.3 los mecanismos vuelven al estado inicial al reaparecer. Los rótulos con letras se sustituyen por flechas, banderas, círculos y marcas; los contadores siguen mostrando iconos y números. Las instrucciones escritas están en pausa. [Contratos y procedencia musical](ARQUITECTURA.md#música-por-nivel-reaparición-y-señales-visuales--060).


## Revisión 0.6.1

La música pasa a **Esmeralda en marcha**: 90 segundos a 128 BPM, batería, bajo y sintetizadores, con una dirección de plataformas moderna y más rítmica. Se eliminan las ayudas flotantes con iconos; los contadores del HUD se mantienen. Las dianas se rompen en ocho fragmentos al recibir un lanzamiento válido y vuelven a estar enteras al reaparecer. También se reparan las de tramos anteriores; puedes romperlas de nuevo sin duplicar la activación de puentes o raíces. Las llaves y los pasos abiertos se conservan. Esta revisión sustituye las reglas visuales de 0.6.0.


### Cambios de jugabilidad y animación · 0.6.3

Al reaparecer en el farol por perder toda la energía, **todos los puentes vuelven a estar recogidos**. Las barreras verticales se cierran, las dianas se reconstruyen y las activaciones se borran para que sea posible superar cada reto de nuevo. Llaves y coleccionables se conservan. Las dianas estallan en cristales irregulares con caída y destello, y Moflete levanta y apoya alternadamente cada pie mientras camina o persigue.


## Actualización 0.7.0 · Nivel más corto y barranco de lianas

Por petición del 17 de octubre de 2026, el nivel jugable contiene diez tramos contando el prólogo (antes 19), 45 enemigos, 10 pasos dobles, cuatro puentes, cinco troncos y las tres llaves de ramas en tres sectores diferentes. La duración objetivo se reduce de 18–22 a **9,2–10,94 min de primera partida estimada**; no hay mediciones físicas del tiempo. El barranco del sector central no admite salto directo: Diego trepa por una liana manteniendo el salto/deslizamiento hacia arriba, suelta y se impulsa hasta una cadena de cinco dianas elásticas. Cada diana se fractura y se rearma tras unos segundos o al reaparecer. La caída resta energía y permite un nuevo intento desde la orilla. Las barreras y los puentes existentes siguen reseteándose si se agotan todas las vidas. Fuente de autoría: `tools/authoring/build_forest_level.py`; recurso de ejecución: `game/data/worlds/world_01/level_01.tres`. [Ficha completa](dinamicas/lianas_dianas_barranco.json).


## Señal del secreto del bosque · Tótem tallado

Junto al borde izquierdo de la trampilla opcional (aprox. **x = 11 430 px**, zona de hojas alrededor de x = 11 610) hay un **tótem original de madera**: rostro amistoso tallado, raíces, copa de hojas y una hoja grabada en el centro. Cuando Diego se aproxima a menos de 390 px, la copa se balancea, flotan tres hojitas y aparece un resplandor suave; fuera de ese radio el elemento queda estático. No hay letras, controles adicionales ni hitboxes en el tótem.

**Cómo entrar:** localizar el tótem, caminar unos pasos a su derecha hasta el centro del grupo de hojas y mantener agacharse (deslizamiento hacia abajo en pantalla, S o flecha abajo con teclado). En el subsuelo espera un brote de vida adicional y un ascensor para regresar a la superficie. El secreto es opcional y no altera las tres llaves ni los puentes. La integración reside en `ForestStage._build_secret()`, el arte autónomo en `game/features/levels/mechanisms/forest_secret_totem.gd`, la comprobación en `test_secret_grove.gd` y la captura en `preview_secret_totem.png`.
