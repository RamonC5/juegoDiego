# Requisitos de personajes

## Requisitos confirmados del proyecto

| Requisito previo | Consecuencia para los personajes |
| --- | --- |
| Plataformas con vista y jugabilidad 2D; rechazo del 3D | Entregar imágenes y animaciones raster 2D de vista lateral. No proponer modelos o escenas 3D como solución |
| Gráficos que no parezcan dibujos; referencias de New Super Mario Bros. U y Donkey Kong Country Returns | Buscar acabado pulido, texturas y sombreado con volumen aparente dentro de la imagen 2D; evitar bocetos, contornos de cómic y acabado plano |
| Elección previa de «opción A» | Mantener esa elección sin inventar su contenido. No consta aquí una ficha visual detallada ni una imagen canónica de esa opción |
| Enemigos normales eliminados saltando encima | Prever una zona superior legible y poses de patrulla, pisotón recibido y derrota según el enemigo solicitado |
| Jefes derrotados mediante objetos lanzados | Prever anticipación, vulnerabilidad, impacto y derrota del jefe; dar legibilidad a manos y objetos en las poses del protagonista |
| Ocho mundos | Permitir asociar un personaje a `world_01`–`world_08` o reutilizarlo en varios. No fijar temáticas ni roster que no existan |
| Volver a los niveles superados | Conservar identificadores y versiones estables; no vincular el aspecto del personaje a un único primer paso por el nivel |
| Android y Windows | Priorizar lectura a tamaño móvil y recursos compartidos entre plataformas; verificar alfa, tamaños y memoria |
| Base Godot 4.7.2, GDScript, Compatibility | Preparar recursos compatibles con `Sprite2D`, `AnimatedSprite2D` y `SpriteFrames`; no exigir shaders avanzados |
| Proyecto creado inicialmente sin contenido | Cuando se mantenga el skill o su arquitectura, no generar personajes ni insertarlos en la escena vacía |

## Criterios técnicos derivados

Aplicar como punto de partida revisable, no como preferencias ya confirmadas por el usuario:

- Usar sprites HD con bordes suaves, filtrado lineal y detalle controlado; evitar pixel art como opción predeterminada para este encargo.
- Trabajar de perfil, orientado a la derecha, con perspectiva y luz constantes. No confundir volumen aparente en una imagen con un recurso 3D.
- Proponer celdas de 256 × 256 para héroes y enemigos normales; 512 × 512 para jefes si lo requiere su silueta. Medir el tamaño real antes de integrarlos.
- Separar estados peligrosos, pisables y vulnerables mediante forma, postura o animación, además de color. No introducir invulnerabilidad, pinchos o armaduras como decisiones de diseño ya tomadas.
- Utilizar identificadores `snake_case`, sin depender del nombre visible.

## Decisiones que siguen abiertas

No consta el nombre, especie, edad, vestuario, paleta o silueta del protagonista; tampoco las temáticas de los ocho mundos, su lista de enemigos o sus jefes. No completar estos campos como canon. Para una solicitud creativa abierta, proponer una identidad original y registrarla como propuesta.

Si el usuario aporta después la descripción o imagen de «opción A», incorporarla a la ficha y usarla como referencia principal. Las instrucciones actuales del usuario prevalecen sobre las propuestas de este documento.
