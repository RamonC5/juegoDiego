# Entrada 0.11.0 · escenas y continuidad

## Cambio

Ocho escenarios laterales a pantalla completa, carrera raster propia de ocho poses, selección de apoyos por distancia, salto balístico, doble impulso continuo, frenada al lanzar y recuperación breve. Se retira la doble silueta del fundido entre fotogramas. Moflete y Nóctilo conservan sus mallas, perfiles y materiales por instancia.

## Comprobaciones

- Godot 4.7.2: importación completa sin errores de script.
- `test_entrance.gd`: 3.939 comprobaciones sin fallos, incluidas dos vueltas de las ocho escenas, trayectorias a 60 Hz, poses, navegación por toque real, bloqueo de los siete mundos, foco, tamaños táctiles y retorno desde pausa. Añade recuperación tras cada acción, opacidad de la silueta, avance local de ambos malvados, 30/60/120 Hz, un fotograma de 0,35 segundos y ocultación inmediata de enemigos al activar movimiento reducido.
- `test_enemy_motion.gd`: 198 comprobaciones sin fallos, incluidos miembros, apoyos, espejo y alas.
- `test_android_readiness.py`: nueve casos sin fallos.

`capture_entrance.gd` captura cada mundo, veinte muestras de las acciones principales, mapa y tablet con movimiento reducido usando Compatibility. Actions vuelve a importar, ejecutar las regresiones, capturar y exportar antes de probar el APK.

Revisión local con Compatibility/llvmpipe: 112 capturas sin errores de renderizado. Se han inspeccionado bosque con perseguidor, pantano con manos ancladas, Nóctilo, salto, mapa y tablet. Esta revisión detectó un malvado residual al activar movimiento reducido mientras el proceso estaba detenido para capturas; se corrige actualizando la visibilidad también en la actualización visual inmediata.

## Recursos y límites

El PNG original de carrera mide 1774 × 887 y no forma una cuadrícula de cuatro columnas divisibles: se usan ocho regiones explícitas, lienzo virtual 1024 × 1024 y raíz común por fila. El comprobador genérico de cuadrícula detecta alfa residual en los bordes del PNG completo; no se declara que esa fuente pase su condición de margen de cuatro píxeles. El shader elimina el alfa residual y el lienzo virtual aporta el margen de dibujo. La revisión debe comprobar el resultado renderizado y la ausencia de recortes en las ocho poses.

Las siete ambientaciones pendientes siguen siendo avances visuales. Los malvados de la entrada no acreditan IA ni combate en mundos bloqueados. Rendimiento y tacto en el móvil Android y la tablet Windows físicos del usuario pendientes.
