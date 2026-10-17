# Movimiento de miembros y alas

Aplicar a personajes nuevos y revisiones; requisito confirmado el 17 de octubre de 2026.

## Anatomía y actuación

- Inventariar brazos, antebrazos, manos, alas, puntas y apoyos visibles antes de animar. Conservar la identidad y no inventar extremidades.
- Mover hombro/codo y muñeca/mano con amplitudes y fases distintas. Mantener uniones suaves y agarres coherentes; evitar manos duplicadas, miembros rígidos y estiramientos del rostro.
- Alternar apoyos al caminar, acelerar progresivamente al perseguir y reducir la zancada al frenar o caer. Añadir movimiento leve en reposo. No reiniciar el ciclo al cambiar de estado.
- Coordinar alas con una frecuencia común y una curva periódica suave, por ejemplo `sin(fase)`. Dar a las puntas una flexión menor con retraso de fase; preservar continuidad de posición y velocidad entre final e inicio. No hacer que cada ala vibre de forma aleatoria o independiente.
- Respetar la especie: Plumín gesticula con su ala plegada; Nóctilo aletea en vuelo. Goterón ondula el gel; Terrón mueve sus raíces. No añadir capacidad de vuelo por el hecho de animar alas.

## Producción y reproducción

1. Elegir `SpriteFrames` con poses reales o malla/rig 2D sobre el raster. Reutilizar el arte existente cuando el encargo sea de animación por código; usar `image_gen` y su skill al crear o editar píxeles.
2. Para poses nuevas, fijar raíz, celda, escala y luz. Pedir posiciones distintas de miembros dentro de cada acción, conservando anatomía y silueta.
3. Para la malla existente, reutilizar `game/features/enemies/enemy_visual.gd`, sus perfiles normalizados en `enemy_motion_profiles.gd` y el shader `enemy_limb_motion.gdshader`. Ajustar pivotes y zonas por personaje después de inspeccionar su PNG; no copiar las coordenadas de otro cuerpo.
4. Conservar un material y una fase por instancia; compartir solo geometría inmutable. Avanzar por `delta` desde el controlador para respetar pausa, distancia y derrota. No usar `TIME` global para ciclos que deben detenerse.
5. Aplicar espejo a toda la malla y mantener el dibujo fuera del cuerpo físico. Conservar sensores de pisotón, contacto y reglas de daño. Detener miembros al derrotar antes de comprimir y desvanecer el conjunto.
6. Documentar frecuencia, amplitud, fases, zonas y acciones cubiertas. Marcar la revisión de dispositivo físico como pendiente cuando no se haya hecho.

## Comprobación de entrega

- Reproducir al menos dos ciclos completos a tamaño de juego y ampliados, sobre fondos claros y oscuros. Revisar uniones, recortes, manos, alas cercanas/lejanas y posibles cambios de silueta pisable.
- Comparar reposo, patrulla, persecución, frenado, caída, pausa, espejo y derrota. Verificar que dos instancias no comparten accidentalmente la fase.
- Ejecutar `tools/tests/test_enemy_motion.gd`, las regresiones de combate/persecución afectadas y una captura con Compatibility. Los ángulos numéricos no certifican por sí solos que el raster se vea animado.
- Usar `game/features/enemies/enemy_gallery.tscn` para revisar el reparto, con pausa y movimiento reducido. Distinguir visor visual y enemigo integrado en un nivel.
- Conservar evidencias y actualizar ficha, `character.json` y `docs/PERSONAJES.md`. No afirmar que existen hojas nuevas cuando se ha animado el PNG mediante malla.


## Evitar animaciones imperceptibles en APK (octubre de 2026)

- Las articulaciones deben definirse en UV relativos al **recorte del personaje**. El shader recibe `region_origin` y `region_extent` desde `EnemyVisual`; nunca mezclar UV del atlas con UV locales para decidir la influencia.
- Junto al giro, permitir desplazamientos localizados periódicos que cambien la silueta a tamaño real de juego (~60–80 px de alto para enemigos terrestres). Calibrar en Android y no solo en el visor ampliado.
- No aceptar únicamente tests de cambios en `pose_angles`: capturar dos poses con el renderizador Compatibility, congelar `position` y `rotation` del sprite completo y contar píxeles cambiados dentro del enemigo.
- Documentar por separado la animación disponible en **visor** y su **aparición jugable** en niveles. Mantener pendientes pruebas físicas cuando no se dispone del dispositivo.


## Requisito de pisada en personajes con pies

- Alternar fase de apoyo y de balanceo entre las dos piernas: un pie avanza elevado mientras el contrario permanece en contacto con el suelo.
- Calibrar al tamaño real del APK, variar amplitud con velocidad de patrulla/persecución y amortiguar al frenar, quedar quieto o saltar. Mantener continuidad de fase y colisiones estáticas.
- Verificar con pruebas la diferencia vertical y horizontal de los dos pies, no solo el balanceo del tronco.
