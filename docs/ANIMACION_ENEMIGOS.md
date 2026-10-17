# Animación de enemigos · Super Diego 0.5.3

Los enemigos mueven sus miembros según su anatomía. El arte raster existente se articula con una malla 2D; no se han generado hojas nuevas ni cambiado las reglas de combate.

| Personaje | Movimiento | Integración |
| --- | --- | --- |
| Terrón | Alternancia de sus dos apoyos de raíz, con paso pesado | Bosque |
| Moflete | Dos brazos y dos manos con flexión desfasada de muñecas; pies alternos | Bosque |
| Goterón | Ondulación desfasada de cuello y cola de gel, sin añadir brazos | Visor visual |
| Vainete | Marcha alternada de sus seis raíces | Visor visual |
| Plumín | Balanceo suave del ala plegada y flexión de plumas, acompañado por las patas | Visor visual; sigue siendo terrestre |
| Remiendo | Balanceo de brazos y manos, con retraso en las muñecas y pasos desiguales | Visor visual |
| Nóctilo | Alas coordinadas con curva senoidal, puntas flexibles con retraso y oscilación del cuerpo | Visor visual; IA de vuelo pendiente |

## Reproducción

`EnemyVisual` conserva el PNG y su recorte normalizado. Una malla compartida de 32 × 32 celdas conserva los UV originales; el shader deforma zonas elípticas alrededor de los pivotes de `EnemyMotionProfiles`. Cada instancia tiene material y fase propios. Los PNG de las cinco integraciones visuales nuevas son copias sin edición de sus conceptos registrados.

Los brazos y manos tienen amplitudes y fases diferentes. Las alas comparten una frecuencia común con desfases pequeños y las puntas se retrasan 0,45 radianes respecto al ala. Nóctilo usa una base de 2,2 Hz en el visor; Plumín gesticula con su ala plegada a 1,2 Hz. La fase se conserva al cambiar la velocidad; la amplitud de las extremidades se reduce en reposo y al caer. Las coordenadas y amplitudes reales están en el perfil de cada personaje.

El controlador del bosque proporciona velocidad real, apoyo y aviso de persecución. Pausa y suspensión lejana detienen el ciclo; la derrota deja de avanzar miembros y comprime/desvanece el conjunto. La animación modifica únicamente dibujo: sensores de contacto y pisotón conservan sus posiciones. La geometría se comparte, los materiales no.

## Revisar los siete diseños

Abrir `game/features/enemies/enemy_gallery.tscn` y ejecutar la escena con F6, o:

```sh
godot --path . game/features/enemies/enemy_gallery.tscn
```

El visor ofrece pausa y movimiento reducido, botones con foco de teclado y etiquetas. Los cinco diseños que no aparecen en el bosque conservan pendientes su IA, combate y colocación en niveles; disponer de animación visual no completa esas tareas.

## Verificación del 17 de octubre de 2026

- Godot 4.7.2: importación y arranque correctos.
- `test_enemy_motion.gd`: **140 comprobaciones, cero fallos**; mallas, movimiento local, orientación, cierre de bucles, instancias independientes, reducción, pausa, pisotón y derrota.
- Regresiones: **61** de bosque, **68** de pulido/persecución y **105** de ampliación, todas sin fallos. Total de esta revisión: **374** comprobaciones.
- Compatibility con Mesa llvmpipe: **24 fotogramas**, dos ciclos completos a 1280 × 720. Revisión de manos de Moflete/Remiendo y alas de Nóctilo en extremos opuestos; movimiento visible y ausencia de extremidades duplicadas. Se conserva una [vista animada](../art/characters/motion_preview/preview.gif).
- La CI ejecuta la suite nueva y conserva las capturas en `enemigos-animaciones-<ejecución>`, además de generar el APK habitual.

La revisión visual usa renderizado de escritorio por software. Las pruebas físicas en Android y tablet Windows, el rendimiento de 60 FPS y la valoración del movimiento con el niño siguen pendientes. El visor permite reducir la animación secundaria; esa opción todavía no forma parte de los ajustes de partida.

El [skill de personajes](../.agents/skills/generar-personajes-salto-heroes/SKILL.md), su contrato de producción y la plantilla de encargo ya exigen miembros móviles, aleteo armónico y comprobación visual de ciclos para los próximos personajes.


## Corrección de legibilidad en Android · 0.6.2

Al observar que los movimientos no se apreciaban en el APK se identificaron dos causas en el código: los perfiles estaban descritos con coordenadas relativas al recorte de cada personaje, pero el shader trataba los valores como coordenadas del atlas completo; y la amplitud en reposo/patrulla era muy pequeña a tamaño móvil. La malla convierte ahora UV globales a coordenadas locales y mezcla flexión y traslación localizada senoidal, con zonas mayores en las manos de Moflete y las raíces de Terrón. El cuerpo físico, sensores y reglas de daño siguen sin modificarse.

**Alcance del APK:** en Bosque Esmeralda aparecen **Terrón y Moflete**. Los otros cinco personajes (Goterón, Vainete, Plumín, Remiendo y Nóctilo) están animados solamente en el visor y aún no se incluyen como enemigos jugables. Las alas de Nóctilo se revisan en `enemy_gallery.tscn`, no en el nivel de bosque.

Se amplió la comprobación automática para validar UV de recorte, continuidad de desplazamientos y cambios de píxeles reales entre poses capturadas con Compatibility **sin balancear el cuerpo entero**. La nueva versión requiere descargar e instalar de nuevo el APK generado por Actions para este commit. La apreciación visual y los FPS en móviles físicos aún requieren comprobación.


## Pisada expresiva de Moflete · 0.6.3

Los pies de Moflete pasan al modo `foot`, con un desfase de PI radianes: uno eleva su extremo en el balanceo mientras el otro está apoyado. La traslación longitudinal y la elevación aumentan al perseguir y se amortiguan en reposo y en el aire. Se comprueba la alternancia de apoyo y elevación en `test_enemy_motion.gd`. La deformación no mueve sensores ni colisiones, y no se modifica el PNG.

## Marcha natural y anatomía estable · 0.7.2

Se reduce el movimiento elástico de manos y pies. La fase de la marcha depende de la distancia real: Terrón usa 96 px por ciclo y Moflete 70 px, de modo que correr acelera la zancada y detenerse la amortigua hasta dejar los apoyos quietos. El pie apoyado queda plano; el otro vuelve por un arco de 4,5 % de la altura del recorte (2,2 % en raíces). Las muñecas siguen el desfase del brazo con desplazamiento de 0,3 % del ancho, en vez del 6 % anterior. El giro se calcula en píxeles para no estirar un recorte rectangular.

La alerta y el estado aéreo se mezclan progresivamente, la caída reduce la marcha y repliega los apoyos, y el cuerpo transfiere suavemente el peso entre ellos. La respiración es secundaria, con 0,6 % de escala y raíz estable. El aleteo conserva su frecuencia armónica y el retraso de las puntas. El controlador físico acelera a 600 px/s² durante persecución y 380 px/s² durante patrulla, conservando la comprobación de bordes y caídas seguras.

`test_enemy_motion.gd`: **198 comprobaciones correctas**, incluidos cierre de ciclo, apoyo plano, parada, reducción, espejo, pausa, derrota y sensores. Terrón y Moflete están en el bosque; los otros cinco siguen en el visor. Prueba física en Android/Windows pendiente.

La captura Compatibility de esta revisión verifica 24 fotogramas (dos ciclos) y cambios reales en el raster, congelando el balanceo global: Terrón 290 píxeles de muestra, Moflete 402 y Nóctilo 2205 entre las poses comparadas. Se revisaron las capturas del reparto y del nivel con Mesa llvmpipe; la revisión no sustituye la prueba de dispositivo físico.
