# Revisión de Diego · 15 de octubre de 2026

## Resultado

Propuesta visual integrada y comprobada en Godot 4.7.2. La foto guía el pelo oscuro, las gafas y la expresión; el vestuario de aventura, el nombre de trabajo y las proporciones siguen como propuestas. El personaje comparte texturas y luz con el reparto sin reutilizar la anatomía de sus enemigos.

## Arte y atlas

- Concepto PNG RGBA de 1254 × 1254: pasa el comprobador del skill.
- Diez hojas RGBA: ocho de 1254 × 1254 y dos de 1536 × 1024; 44 poses fuente, 13 estados de ejecución.
- Las hojas generadas conservan píxeles de alfa residual y algunas poses cruzan la cuadrícula ideal. El informe del comprobador original conserva esos avisos; **las hojas fuente no pasan la comprobación estricta de cuadrícula y margen**.
- La integración usa regiones explícitas `AtlasTexture`, margen en un lienzo virtual, pivotes de apoyo, escala uniforme por hoja y `filter_clip`. El shader descarta el alfa de baja opacidad con transición suave. No se han recortado, reescalado ni retocado los PNG por código.
- Las 44 regiones efectivas pasan la comprobación de contenido, margen virtual y apoyo. No hay errores de regiones ni poses vacías. El detalle está en [qa-technical.json](qa-technical.json).
- La revisión renderizada muestra cuerpo y botas completos, gafas legibles, vestuario consistente y poses diferenciadas. Se han revisado estados sobre fondos claros y oscuros. Los ciclos son una primera animación para probar; el ajuste artístico fino y de sensaciones continúa tras la valoración del usuario.

![Trece estados de Diego renderizados en Godot sobre fondos claros y oscuros: reposo, caminar, correr, salto, caída, aterrizaje, sostener, transportar, recoger, lanzar, daño, derrota y victoria.](preview_animations.png)

## Motor y comportamiento

Importación y arranque sin errores de scripts en Godot **4.7.2.stable.official.ed1daf0bf**. Se ejecutaron **55 comprobaciones con cero fallos** usando la física y las escenas reales del motor. [Salida de las pruebas](qa-tests.txt).

Cubren apoyo, aceleración, carrera, frenado, altura de salto, salto completo con pulsación, tolerancia al borde y al aterrizaje, rechazo de pisotón al ascender/contactar desde abajo o lateralmente, rebote por sensor, recogida, suelta única, objeto físico independiente, daño, protección, derrota, reaparición, tres contactos simultáneos, eje analógico y origen flotante, cruce de mitades, toque único, salto por gesto, cancelación, rechazo de ratón emulado, pausa sin órdenes fantasma, cambio de lados, recorrido ajustable, proporciones 16:9 y 4:3, migración de ajustes y reasignación que conserva el mando. Las alturas medidas fueron 36,12 y 107,98 px para salto corto y mantenido.

## Revisión gráfica

Capturas reales del motor con **Compatibility, OpenGL 4.5 y Mesa llvmpipe**, en una pantalla virtual X11. Se comprobó:

- [Entrenamiento a 1280 × 720](preview_gameplay.png): transparencia, escala y lectura del protagonista, HUD y guía inicial de gestos.
- [Dos gestos activos](preview_gestures.png): movimiento y salto simultáneos, con trazos donde se apoyan los dedos.
- [Pantalla despejada](preview_clean.png): la guía desaparece y no hay botones de juego.
- [Pausa y ajustes](preview_controls.png): encabezado y acciones fijas, foco visible, casillas con contraste y opciones en una zona desplazable.
- [Formato tablet a 1024 × 768](preview_tablet.png): distribución, zonas amplias y ayuda dentro del área visible.
- [Estados en claro y oscuro](preview_animations.png): recortes, identidad y poses.

Los avisos del entorno sobre `/proc/self/exe` y VSync de la pantalla virtual no son errores del proyecto. La última captura usó audio Dummy porque este entorno no tiene dispositivo de sonido.

## Límites y trabajo posterior

No se certifican todavía dispositivos físicos Android/Windows, lectores de pantalla nativos, tacto real ni 60 FPS. El cálculo RGBA8 de las diez hojas ronda 60 MiB antes de compresión y no mide VRAM de un teléfono. El arte fuente conserva los avisos descritos: su reutilización sin el atlas y shader actuales requiere limpieza de margen/alfa mediante el flujo de imágenes.

Quedan la valoración visual del usuario y la descripción detallada de «opción A». Los ocho mundos, niveles rejugables, enemigos y jefes completos siguen fuera de esta prueba del protagonista. La CI ejecuta las pruebas antes de generar el APK; el estado de cada build se consulta en Actions.


## Agacharse · 16 de octubre de 2026

Se añade `crouch_v001.png`, generado con `image_gen` a partir de `concept_v001.png`, sin modificación de píxeles por código. Cuatro poses con rodillas flexionadas, manos sobre las rodillas, gafas y vestuario conservados; vista hacia la derecha y respiración sutil a 5 FPS. El PNG RGBA mide 1536 × 1024. El 72,36 % de los píxeles tienen alfa cero.

La cuadrícula nominal 2 × 2 conserva avisos de margen y alfa residual: la primera fila llega a y=518. Se registran en `crouch-source-check.json`; el juego usa regiones explícitas separadas y el shader de alfa ya existente. La revisión de las 48 regiones de atlas pasa sin errores, con apoyo estable y márgenes virtuales. No se presenta la hoja como una cuadrícula regular lista para otros motores.

Godot 4.7.2: importación y arranque correctos. **206 comprobaciones sin fallos**: 88 de protagonista y controles, 63 de objetos y 55 de bosque y llaves. Incluyen altura reducida, apoyo de pies, techo a 70 px, recuperación al despejarlo, instancia independiente, entrada durante la caída, daño, reaparición, objeto sostenido, prioridad sobre salto, multitáctil, cancelación, pausa, foco y reasignación conservando el mando. Evidencia: `qa-crouch-tests.txt`.

Los scripts de captura incluyen la postura nueva en móvil y tablet. La CI los ejecuta con Compatibility antes de exportar el APK. Las pruebas en Android y tablet Windows físicos siguen pendientes.

Revisión gráfica realizada con Compatibility, OpenGL 4.5 y Mesa llvmpipe: `preview_crouch.png` (1280 × 720), `preview_crouch_tablet.png` (1024 × 768) y `preview_animations.png` con los 14 estados sobre fondos claros y oscuros. La postura baja es legible y mantiene los pies en la raíz sin recortes. La guía incluye agacharse y el menú presenta la acción reasignable. También se comprueba celebrar al entrar agachado en un sensor de meta.


## Doble salto y agarre · 0.7.3

Validado con Godot 4.7.2: **817 comprobaciones de comportamiento, 0 fallos**, además de cuatro regresiones Python del APK y validación de la ficha de lianas. El informe estructurado está en [movement-qa-2026-10-17.json](movement-qa-2026-10-17.json). Las entradas táctiles reales se verifican con la física: primera pulsación, segunda durante el vuelo y tercera ignorada. La reserva tras pisotón, borde, liana y reaparición también se prueba.

Las capturas Compatibility de [Actions 144](https://github.com/RamonC5/juegoDiego/actions/runs/39067277904), artefacto `diego-movimientos-144`, muestran la nueva pose dentro del bosque. Se ha revisado la vista móvil: manos en contacto con el nudo, piernas suspendidas y materiales coherentes con Diego. La versión final del capturador centra también las vistas ampliadas y espera pasos físicos. El punto de agarre permanece a menos de 0,1 px del nudo en 480 pasos con cambios de orientación; es una comprobación geométrica además de la revisión visual. La pose es única, sin afirmar una hoja animada nueva de varias poses.

No se ha probado el tacto ni el rendimiento en los dispositivos Android y Windows físicos del usuario.
