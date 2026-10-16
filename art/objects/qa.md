# Revisión de objetos arrojadizos

Entrega de seis propuestas: barril de raíces, canto de río, piña del bosque, vasija de barro, bloque de hielo y vaina resorte. Todos están disponibles en el primer tramo del entrenamiento de Diego. Nombres y parámetros de balance siguen siendo propuestas.

## Verificación completada

| Área | Evidencia |
| --- | --- |
| Motor | Godot 4.7.2 estándar; ejecutable oficial comprobado contra el SHA-512 fijado en el proyecto |
| Importación y arranque | Importación de los recursos y arranque del entrenamiento sin errores de script |
| Protagonista y gestos | 55 comprobaciones existentes superadas |
| Objetos | 63 comprobaciones físicas superadas: catálogo, carga de las seis texturas, recogida y doble recogida, suelta sin daño, lanzamiento hacia la izquierda y normalización de la escala de la mano, impacto único, pared fina, rodadura, deslizamiento, rebotes, rotura, recuperación, caducidad, cancelación de reposición y presencia en la escena principal |
| Arte | Seis PNG RGBA reales de 1254 × 1254, con transparencia; lectura y contenido no vacío comprobados por el validador del proyecto |
| Importación móvil | Límite de 256 × 256, sin mipmaps; aproximadamente 1,5 MiB de texels RGBA8 para las seis texturas, sin contar estructura del motor |
| Renderizado | Compatibility / OpenGL sobre llvmpipe; revisión gráfica a 1280 × 720 y 1024 × 768 |
| Documentación | Seis fichas con imagen, datos, prompt exacto, metadatos y resultados de lectura |

Los registros de las pruebas están en [qa-tests.txt](qa-tests.txt). La CI ejecuta los 118 controles de comportamiento antes de generar el APK de pruebas.

## Revisión visual

Se revisaron juntas las seis siluetas, materiales y colores sobre fondos claros y oscuros. Barril circular y madera con aros, piedra asimétrica con vetas, piña alargada con escamas, vasija con cuello y asas, bloque angular de hielo y vaina curva con semillas se distinguen por su forma además del color. Las figuras mantienen el acabado raster texturizado y la iluminación superior izquierda del proyecto.

El catálogo se renderiza con las texturas importadas de 256 píxeles, no con copias de mayor resolución. En partida los anchos visibles propuestos son de 32 a 48 píxeles. Se revisaron el agarre, la proporción con Diego y la separación de la diana de pisotón. Los nombres y el comportamiento se muestran también con texto. La cámara no añade sacudidas y no se introducen destellos.

- [Catálogo sobre fondos claros y oscuros](preview_catalog.png).
- [Entrenamiento con los seis objetos](preview_gameplay.png).
- [Diego sosteniendo el barril](preview_carry.png).
- [Tablet en proporción 4:3](preview_tablet.png).

## Alfa de las imágenes originales

Los originales generados contienen píxeles de alfa muy bajo fuera de la silueta. Por eso la comprobación estricta de margen de cuatro píxeles falla en los seis archivos; los informes `qa-strict-margins.json` conservan ese resultado real. El validador con `--min-padding 0` confirma el formato, transparencia y contenido no vacío, sin certificar limpieza de bordes.

La integración usa regiones normalizadas que enmarcan la figura visible, filtrado lineal y el shader de alfa que ya utiliza Diego (`smoothstep(0.13, 0.40, alpha)`). Se revisó que los restos no sean visibles sobre los dos fondos del catálogo. Se conservan los PNG originales sin modificación de alfa. Las capturas son composición y renderizado de Godot con los recursos reales.

## Alcance y pendientes

Hay una imagen fuente por objeto: vuelo, rodadura y rebotes se animan mediante transformaciones de la entidad. La rotura de la vasija desactiva la colisión y oculta su sprite; no tiene todavía fragmentos animados ni sonido. Los jefes y las vulnerabilidades concretas siguen pendientes; las dianas comprueban el contrato de recepción de objetos.

La recuperación por límites y la reposición se configuran explícitamente en el entrenamiento y quedan desactivadas por defecto para otros niveles. Los ocho mundos no reciben nuevas temáticas ni ubicaciones definitivas de estos objetos.

Quedan las pruebas en Android y tablet Windows físicos, la sensación táctil, el rendimiento de GPU y el balance con niveles y jefes reales. La revisión gráfica en Linux y las pruebas headless no sustituyen esas comprobaciones.
