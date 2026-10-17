# Nóctilo · enemigo volador de Super Diego

**ID:** `noctilo` · **Rol:** enemigo normal volador, eliminable por pisotón.  
**Diseño:** propuesto · **Versión visual:** 002 · **Fecha:** 16 de octubre de 2026. Sin mundo exclusivo asignado.

![Nóctilo de perfil en vuelo: murciélago de pelaje berenjena, alas angulosas cobrizas, orejas grandes y mirada ámbar desconfiada.](concept_v002.png)

## Identidad y personalidad

**Desconfiado, nervioso y sigiloso.** Vigila todos los ruidos, incluido su propio eco. La pose mantiene una oreja atenta hacia delante y la otra hacia atrás; los pies recogidos dejan claro que está volando.

| Rasgo | Propuesta |
| --- | --- |
| Silueta | Cuerpo suspendido y afinado, grandes alas angulosas con membrana festoneada y orejas largas. |
| Rostro | Hocico corto, ceja alerta, ojo ámbar oblicuo y boca tensa. |
| Materiales | Pelaje corto berenjena, garganta gris lavanda y membranas cobrizas con pliegues suaves. |
| Pose clave | Aleteo ascendente de perfil hacia la derecha; ala cercana alta y lejana más baja. |
| Gesto propio | Escucha en dos direcciones; al sobresaltarse abre las alas de golpe. |
| Parte pisable | Cabeza blanda, sin casco, pinchos ni cuernos. La pose de recepción deberá recoger las orejas. |

Frente a Plumín, tiene alas membranosas grandes en lugar de plumas, cuerpo suspendido en lugar de pecho erguido sobre patas largas y mirada alerta en lugar de gesto presumido. Frente a Moflete, presenta torso afinado, orejas largas y patas recogidas, sin las grandes mejillas ni la postura erguida del roedor. Su identidad se distingue por forma, cara y postura además del color.

## Vuelo y respuesta propuestos

| Fase | Lectura prevista |
| --- | --- |
| Patrulla | Vuelo bajo con una oscilación suave, a una altura alcanzable por el salto de Diego. |
| Escucha | Se suspende brevemente y orienta las orejas; muestra su carácter nervioso. |
| Aviso de picado | Recoge parte de las alas e inclina el cuerpo antes de atacar. |
| Picado y recuperación | Descenso corto y regreso a su ruta, sin persecución indefinida. |
| Pisotón | Recoge las orejas, pliega las alas y cae derrotado al recibir el salto desde arriba. |

Estas fases son una propuesta de diseño; no se han programado ni animado. La altura, velocidad, anticipación y rebote se ajustarán al integrarlo. Colisiones y sensores serán independientes del alfa. La respuesta a objetos lanzados se conectará al contrato existente al implementar el enemigo.

El aviso debe comunicarse mediante postura y movimiento, sin depender solo del color o de un sonido. No se proponen destellos ni sacudidas.

## Imagen y estado real

[concept_v002.png](concept_v002.png) es un **PNG RGBA de 1254 × 1254 px**, con transparencia real, una pose estática y margen mínimo medido de **22 px**. Ha pasado el comprobador del proyecto. La [versión original](sources/concept_v001.png) se conserva como referencia; su alfa residual fue corregido mediante una segunda llamada a la herramienta de imágenes.

Estado: **concept_only**. El nombre, la paleta, la personalidad y el patrón de vuelo son propuestas nuevas. La petición de crear el enemigo no se registra como aprobación de esta imagen concreta.

El personaje conserva el contexto 2D HD para Android y Windows, ocho mundos y niveles rejugables. La descripción completa de «opción A» sigue pendiente de incorporarse. Las celdas de 256 × 256 y el ancla de vuelo [128, 160] son propuestas aún sin verificar; no hay secuencias, `SpriteFrames` ni integración jugable.

## Archivos

- [Encargo y decisiones](brief.yaml).
- [Prompts exactos, referencias y versiones](prompts.md).
- [Metadatos y plan de producción](character.json).
- [Revisión visual](qa.md), [informe técnico final](qa-technical.json) e [informe de la fuente](qa-source-v001.json).

Volver al [catálogo de personajes](../../../docs/PERSONAJES.md).



## Movimiento articulado · 17 de octubre de 2026

El raster existente tiene animación por malla 2D con perfiles propios de anatomía. Coordina las dos alas con curva senoidal continua, flexión desfasada en las puntas y oscilación leve del cuerpo. No hay hojas de fotogramas nuevas.

La animación se revisa en `enemy_gallery.tscn`; su IA, combate y colocación en niveles siguen pendientes. Los sensores permanecen independientes del dibujo. [Contrato, visor y verificación](../../../docs/ANIMACION_ENEMIGOS.md).
